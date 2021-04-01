-- VOD 선결제 구매건 
select 
'VOD' 상품구분,
buy_dh 구매일시, sc_id 스마트카드번호 , a.vod_id,c.title, 
--AF_INVCE_YN,
--AF_INVCE_AMT,   
PAY_TRNSN_ID , 
b.scrbr_nm 가입계약명, 
--b.sale_type_cd ,
'위성' 가입구분, 
case when b.sale_type_cd = '2' or scrbr_nm like '%사업용%' then '사업용' 
end 사업용구분,
d.cd_nm 결제수단,
--usg_amt "매출(부가세제외)",
--trunc(PRDT_PRCE*1.1,-1) "가격(부가세포함)", 
--trunc(PREPAY_AMT*1.1,-1) "선결제금액(부가세포함)",
trunc(PREPAY_AMT*1.1,-1) "정산금액(부가세포함)",
PREPAY_AMT
from cmcb15t01 a, cmcc01t01 b, mmab06t01 c, zzaa02t01 d
where  buy_dh like :mm||'%'
--and af_invce_yn ='N'
and a.scrbr_no = b.scrbr_no
and a.prepay_amt <> 0
and a.vod_id = c.vod_id
and a.PAY_MTH_CD = d.cd
and d.cd_cl ='CM448'
and nvl(a.cncl_yn,'N') = 'N'
and a.pay_mth_cd in ( '03')

select * from cmcc03t01 where AF_INVCE_YN = 'N'
and PAY_TRNSN_ID is not null

select * from cmcc02t01 

select * from cmcc04t01 where scrbr_no ='0012673895'

select * from mmda03t01 where equip_model_no ='UHD-0403'



select
substr(구매일,1,6),
pay_mth_cd,
count(distinct scrbr_no) 이용자수,
count(*) 주문건수, 
sum(usg_amt) 매출,
sum(AF_INVCE_AMT) 청구매출,
sum(PREPAY_AMT+PNT_AMT) 선결제매출
from (
	select substr(buy_dh ,1, 8) 구매일, title,
	--decode(g.scrbr_no,'','','멀티룸') 멀티룸여부,
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'dy') 요일, 
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'iw') 주차, 
	pay_mth_cd,
	usg_amt ,a.scrbr_no , a.AF_INVCE_AMT, a.PREPAY_AMT, a.PNT_AMT	
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between  '20200101' and '20200131'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	--and a.scrbr_no='0000737728'
	and   PAY_TRNSN_ID is not null 
)group by substr(구매일,1,6),pay_mth_cd



-- VOD  종량제 선결제 매출                                                      
select  substr(구매일시,1,6),  pay_mth_cd, sum(PREPAY_AMT), sum(PNT_AMT), sum(usg_amt)                                                           
from (                                                                                         
select                                                                                         
sc_id ,                                         
usg_amt,                                                                                       
PREPAY_AMT , 
PNT_AMT,                                                                                  
buy_dh 구매일시,   pay_mth_cd                                                        
from cmcb15t01 a                                     
where  buy_dh like '202001%' -- 사용월기준                                                                    
--and af_invce_yn ='N'                                                                         
--and (a.prepay_amt <> 0 or pnt_amt <> 0 ) 
and nvl(a.cncl_yn,'N') = 'N'
and PAY_TRNSN_ID is not null                                                                             
) group by substr(구매일시,1,6), pay_mth_cd

select * from zzba03t01 where sys_auth_nm like '%시스템%'

insert into zzba03t01 (USER_ID, SYS_AUTH_NM,  REGR_DT, REGR_USER_ID)
values ('01176','시스템운용자','20200819','01141')

commit;

SELECT * FROM ZZAA02T01 WHERE CD_CL ='CM454'
and CD_nm like '상담원%' 

SELECT * FROM ZZAA02T01 WHERE CD_CL ='CM454'
and '20200819' between adpt_fr_Dt and adpt_to_dt
and cd_eng_nm is not null
order by cd_desc desc 

SELECT * FROM ZZAA02T01 WHERE CD='E01A1000006' and CD_CL ='CM454'


SELECT * FROM ZZAA02T01 WHERE CD_nm like '상담원 VOC 100%' 

select * from cmcb19t01 a, zzaa02t01 b
where a.COUPON_CD = b.CD
and b.cd_cl ='CM454'
--and g.cd_eng_nm in (435,436,437) 
--and h.COUPON_CD in ('E01A0500001', 'E01A1000002', 'E03A1000003')


-- crg 쿠폰사용내역 조회 
select 
    substr(buy_dh ,1, 8) 구매일,
    COUPON_ISSUE_CD 쿠폰코드,
    case  when COUPON_ISSUE_CD = '67' then '신규'  
      when COUPON_ISSUE_CD = '127' then '교체'  
      when COUPON_ISSUE_CD = '134' then '이전'  
      when COUPON_ISSUE_CD = '160' then 'AS'  
      when COUPON_ISSUE_CD = '435' then 'CRG 5천원'  
      when COUPON_ISSUE_CD = '436' then 'CRG 1만원'  
      when COUPON_ISSUE_CD = '437' then 'CRG 1만원(dps)'  
      when COUPON_ISSUE_CD is not null then '기타'
end 쿠폰구분,
 decode(a.DISC_AMT,0,'미할인','', '미할인', decode(COUPON_ISSUE_CD,'','skyA할인','쿠폰할인')) 쿠폰할인여부,
     title,a.VOD_ID,
		case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,
	a.PRDT_PRCE 가격,
	a.DISC_AMT 할인,	
	AF_INVCE_AMT 청구금액,
	usg_amt 매출, 
	AF_INVCE_YN 청구여부,
	round(a.DISC_AMT / a.PRDT_PRCE *100,0) 할인율,
	a.scrbr_no 가입계약번호, scrbr_nm 가입계약명, a.sc_id , 
	h.REGR_USER_ID
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f,  cmcb19t01 h
	where a.VOD_ID = b.vod_id
	and a.buy_dh between '20200101' and '20200331'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'	
	and buy_type_cd ='1'  -- 종량제 구매건만 
	and a.DISC_AMT > 0   -- 할인된것
	--AND COUPON_ISSUE_CD in (435,436,437) -- CRG
	and a.SCRBR_NO = h.scrbr_no(+)
	and a.sc_id = h.sc_id(+)
	and decode(a.COUPON_ISSUE_CD, 435,'E01A0500001', 436,'E01A1000002', 437,'E03A1000003', 'E01F1000001') 	 = h.COUPON_CD
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)