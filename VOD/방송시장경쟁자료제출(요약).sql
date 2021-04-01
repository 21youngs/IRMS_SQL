
-- 1. 종량제청구매출, 2.종량제 선결제매출, 3.월정액청구 매출을 CP 분류 기준으로 산출하여 통합하여 결과 합산
-- 결과시트에서 종량제매출(CP분류기준), 월정액매출(CP분류기준) 으로 나오면 됨.

-- 1. 방송시장경쟁상황평가 자료제출 cp분류별 청구매출, (요금DB)
select
-- a.invce_yymm 청구월,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyy') 기준연도,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end 콘텐츠분류,
c.cp_nm ,
--c.CONTENTS_CATE,
count(distinct a.scrbr_no)  사용자수,
--sum(chrg_amnt) 금액,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구할인금액,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구금액
from BILNG_TXN_INFO a, CHRG_INFO b, mmab06t01@LN_SCISCM_MM c
where a.invce_yymm >= '201902' and a.invce_yymm <= '202101'
and a.unit_svc_cd = 'VOD'
and a.invce_yymm >= '201902' and a.invce_yymm <= '202101'
and b.unit_svc_cd = 'VOD'
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.vod_id(+)
group by to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyy') ,
c.cp_nm ,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end



-- 2. 방송시장경쟁상황평가 자료제출 cp분류별 VOD 종량제 선결제 매출 (고객DB, 선결제자료는 요금에 없음)
select  substr(구매일시,1,4) 기준연도,
substr(구매일시,1,6) 기준월,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end 콘텐츠분류,
CP_NM,
count(distinct scrbr_no)  사용자수,
sum(usg_amt)   선결제금액
from (
select
b.scrbr_no , b.scrbr_nm 가입계약명,sc_id ,
usg_amt,
PREPAY_AMT ,
PNT_AMT,
buy_dh 구매일시, d.cd_nm 결제수단,
a.vod_id,c.title, main_cate_nm , sub_cate_nm , CONTENTS_CATE, CP_NM, DISTR_CMPY, PRDT_CMPY
from cmcb15t01 a, cmcc01t01 b, mmab06t01 c, zzaa02t01 d
where  buy_dh > '201901' and buy_dh < '202101' 
--and af_invce_yn ='N'
and a.scrbr_no = b.scrbr_no
and (a.prepay_amt <> 0 or pnt_amt <> 0 )
and a.vod_id = c.vod_id
and a.PAY_MTH_CD = d.cd
and d.cd_cl ='CM448'
and nvl(a.cncl_yn,'N') = 'N'
order by buy_dh
) group by substr(구매일시,1,4), substr(구매일시,1,6) ,
CP_NM,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end


-- 3. 방송시장경쟁상황평가 자료제출 cp분류별 월정액 매출 (요금DB)
select /*+ USE_HASH(b a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyy') 기준연,
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%지상파%' then '지상파'
	 when prdt_nm like '%CJ%' or prdt_nm like '%투니버스%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%캐치온%' then '영화'
	 else '기타'
end 구분,
b.prdt_nm 월정액상품명,
count(distinct scrbr_no)  사용자수,
sum(invce_amt-disc_amt)  VOD월정액청구매출
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201902' and a.invce_yymm <= '202101'
and a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyy'),
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm'),
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%지상파%' then '지상파'
	 when prdt_nm like '%CJ%' or prdt_nm like '%투니버스%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%캐치온%' then '영화'
	 else '기타'
end ,
b.prdt_nm
order by 3,4
