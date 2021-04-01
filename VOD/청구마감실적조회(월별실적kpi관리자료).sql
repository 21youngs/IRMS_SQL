                                                               


-- VOD 종량제 청구금액, 요금디비접속 조회
select 
-- a.invce_yymm 청구월,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--count(distinct a.scrbr_no)  사용자수,
--sum(chrg_amnt) 금액,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구할인금액,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구금액  
from BILNG_TXN_INFO a, CHRG_INFO b  
where a.invce_yymm >= '202008' and a.invce_yymm <= '202010'  -- 청구월기준 
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '202008' and a.invce_yymm <= '202010'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
group by a.invce_yymm
order by a.invce_yymm

-- VOD  종량제 선결제 매출,  고객디비 접속 조회                                                    
select  substr(구매일시,1,6) 기준월, sum(PREPAY_AMT) 카드휴대폰결제, sum(PNT_AMT) 포인트결제, sum(usg_amt) 선결제총매출                                                          
from (                                                                                         
select                                                                                         
b.scrbr_no 가입계약번호, b.scrbr_nm 가입계약명,sc_id ,                                         
usg_amt,                                                                                       
PREPAY_AMT , 
PNT_AMT,                                                                                  
buy_dh 구매일시, d.cd_nm 결제수단,                                                             
a.vod_id,c.title, main_cate_nm , sub_cate_nm , CONTENTS_CATE, CP_NM, DISTR_CMPY, PRDT_CMPY     
from cmcb15t01 a, cmcc01t01 b, mmab06t01 c, zzaa02t01 d                                        
where  buy_dh like '202009%' -- 사용월기준                                                                    
--and af_invce_yn ='N'                                                                         
and a.scrbr_no = b.scrbr_no                                                                    
--and (a.prepay_amt <> 0 or pnt_amt <> 0 ) 
and PAY_TRNSN_ID is not null                                                                          
and a.vod_id = c.vod_id                                                                        
and a.PAY_MTH_CD = d.cd                                                                        
and d.cd_cl ='CM448'                                                                           
and nvl(a.cncl_yn,'N') = 'N'                                                                   
order by buy_dh                                                                                
) group by substr(구매일시,1,6)


-- VOD 월정액 매출, 요금디비조회
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--b.prdt_nm 상품코드명,
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008'  --청구월기준
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm 
--,b.prdt_nm


-- 2018092 상품 극장동시 sky17 상품  청구금액 조회 요금디비조회
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,  
a.prdt_cd 상품코드,
b.prdt_nm 상품코드명,
sum(a.invce_amt-a.disc_amt) 매출,
count(a.scrbr_no) 가입자수
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm = '202008'  -- 청구월기준 
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd = '2018092'
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ,  
a.prdt_cd ,
b.prdt_nm	

-- vod5k, 18k  상품  청구금액 조회, 요금디비조회
SELECT /*+ USE_HASH(b a) */  
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월, 
a.prdt_cd 상품코드,
b.prdt_nm 상품코드명,
sum(a.invce_amt-a.disc_amt) 매출,
count(a.scrbr_no) 가입자수
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm = '202008'  -- 청구월기준
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd in ( '2019009', '2020007')  -- 2019009 5K, 2019010 18K, 2020007 18K(청구목적 가상코드)
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') , 
a.prdt_cd ,
b.prdt_nm


-- 토핑 월정액 매출, 요금디비조회
select /*+ USE_HASH(b a) */   
invce_yymm 청구월,  
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
substr(b.prdt_nm,1,3),
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm = '202008'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('34')
group by invce_yymm  ,substr(b.prdt_nm,1,3)


-- 위성 PPV 청구요금 , 요금디비조회
select
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  위성PPV청구금액
from BILNG_TXN_INFO a, CHRG_INFO b
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008' --청구월
and a.unit_svc_cd = 'PPV' 
and b.invce_yymm >= '202008' and a.invce_yymm <= '202008'  -- 청구월
and b.unit_svc_cd = 'PPV' 
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
group by a.invce_yymm
order by  a.invce_yymm



-- OTS PPV 청구요금 , 요금디비조회
select 
--invce_yymm 청구월, 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--to_char(ADD_MONTHS ( to_date(max(invce_yymm),'YYYYMM') , -1 ),'YYYYMM') , 
sum(chrg_amnt)	OTS청구매출	
from bilng_txn_info	a	
where invce_yymm  >= '202008' and a.invce_yymm <= '202008'  --청구월
and unit_svc_cd = 'KTPPV'	
group by invce_yymm	
order by 1

007005

--  PPV 월정액 청구매출 , 요금디비조회   2020.5월  PPV월정액 분류기준 수정후                                                     
select /*+ USE_HASH(b a) */                                                    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월, 
--b.prdt_nm,
      sum(invce_amt-disc_amt) PPV월정액청구매출                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008'    --청구월                                            
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%PPV%'                                                          
group by invce_yymm     
--, b.prdt_nm                                                       



-- ppv 선결제 
select substr(구매일시,1,6) 월 ,
-- 결제수단,  
sum(usg_amt ) PPV선결제매출
--, sum(usg_amt )*1.1
from (
SELECT
'PPV' 상품구분,
 a.recv_dh 구매일시 , a.sc_id 스마트카드번호,  b.PPV_SVC_ID vod_id, b.pgm_nm title, 
 --c.chl_no 채널번호, c.chl_nm 채널명,
 PAY_TRNSN_ID PAY_TRNSN_ID,
 g.scrbr_nm 가입계약명,
 decode(f.scrbr_no ,null,'위성','OTS') 가입구분, 
case when g.sale_type_cd = '2' or g.scrbr_nm like '%사업용%' then '사업용' 
end 사업용구분,
 e.cd_nm 결제수단,
a.usg_amt ,
--trunc(PRDT_PRCE*1.1,-1) "가격(부가세포함)", 
--trunc(PREPAY_AMT*1.1,-1) "선결제금액(부가세포함)",
trunc(PREPAY_AMT*1.1,-1) "정산금액(부가세포함)"
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g
	   WHERE a.ppv_svc_id = b.ppv_svc_id
	     AND a.brdcst_fr_dh = b.svc_open_dh
	     AND b.chl_no = c.chl_no
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt
	     AND c.vtrl_chl_yn = '1'
	  AND A.CNCL_YN='1'
	  and a.PAY_MTH_CD=e.cd(+)
	  and e.cd_cl(+)='CM448'
	  and a.recv_dh like '202007%'
	  and a.scrbr_no = f.scrbr_no(+)
	  and a.scrbr_no = g.scrbr_no(+)
	  and ( PAY_TRNSN_ID is not null or order_path_cd like '8%' )
	  --and a.order_path_cd like '8%' 
	  and  PAY_TRNSN_ID is not null
)	  
group by  substr(구매일시,1,6)
--, 결제수단



-- 7. IP연결가능 수신기 유지가입자수 조회(월간)
select 
substr(a.dt,1,6) 월,
dt 기준일, /*
		case 
	   when equip_model_nm like '%안드로이드%' then '안드로이드'
	   when equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류, */
 sum(a.MAIN_CNT) 유지수
from mmec50t01 a, mmda03t01 b , zzaa02t01 c
where dt in ( '20200731')
and a.equip_model_no = b.equip_model_no
and b.stb_grp_cd = c.cd
and c.cd_cl ='MM083'
and IP_YN ='0'
and c.cd_nm not like '%OTS%'
group by  dt


-- ip연결유지 
select substr(nalja,1,6) mm , count(*)
from aptest.ip_callback_new_report a 
where nalja in ('20200731') 
and a.gubun = '연결유지'
group by substr(nalja,1,6)



-- 6. 기간별 vod 사용자수 조회
select
--x.수신기분류, x.영업단,x.영업단code,
-- 지사,
--sum(decode(buy_type_cd,'1',count(distinct scrbr_no)) )유료사용자수,
max(구매일) dt,
count(distinct 사용자) 종량제사용자수,
count(distinct 유료사용자) 종량제유료사용자,
count(distinct 사용자) - count(distinct 유료사용자) 종량제무료사용자,
sum(decode(buy_type_cd,'1',usg_amt,0)) VOD매출
from (
	select substr(buy_dh ,1, 8) 구매일, title,
		case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,
	usg_amt ,
	buy_type_cd, 
	h.crcl_net_nm 영업단 ,h.crcl_net_cd 영업단code,  g.crcl_net_nm 센터, i.crcl_net_nm 지사,
	decode(buy_type_cd,'1', a.sc_id,'') 유료사용자,
	decode(buy_type_cd,'2', a.sc_id,'') 월정액사용자,
	a.sc_id 사용자
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, mmca01t01 g, mmca01t01 h, mmca01t01 i
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between  '20200701' and '20200731'||'999999'				
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	--and a.scrbr_no='0000737728'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'	
	--and buy_type_cd ='1'  -- 종량제 구매건만 
	and c.instal_crcl_net_cd = g.crcl_net_cd
	and g.MGMT_BIZ_OFCE_CD = h.crcl_net_cd
	and g.A_RSLT_MGMT_BIZ_OFCE_CD = i.crcl_net_cd
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
)x 



-- 월정액가입자수 , sky17,vod월정액,토핑 중복제외 가입자수 
select  mm 월	, count(distinct scrbr_no) 월정액상품유지수
from (
        (
		-- 월정액가입
		select  --+ parallel (a)
		        mm,  a.scrbr_no 
				from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
				    ( /* 월말 구하기 */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
				where a.svc_open_dh <  d.mm||'31999999'
				and nvl(a.rscs_dh,'29991231') > d.mm||'01' -- 당월해지포함
				and a.scrbr_no=b.scrbr_no
				and a.prdt_cd=c.prdt_cd 
				and B.SALE_TYPE_CD='1'
				and b.scrbr_nm not like '%사업용%'
				and c.prdt_type_cd in ('25','26','34')				
				group by 	mm,  a.scrbr_no		
		)
		union all															
        (
		-- 토핑월말유지수,skyA17
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
		 ( /* 월말 구하기 */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
		where  a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- 당월해지포함
		AND a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and (c.prdt_type_cd in ('34') or c.prdt_cd ='2018010')  -- skyA 17   
		--and a.prdt_cd in ('2018018', '2019001')
		and b.SALE_TYPE_CD='1'
		and b.scrbr_nm not like '%사업용%'
		group by 	mm,  a.scrbr_no						
		)					
)group by 	mm


-- 토핑 가입자수(당월해지포함)
select  '토핑' 구분, mm, prdt_nm	, 
count(*)
from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
 ( /* 월말 구하기 */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202101'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
where  a.svc_open_dh <  d.mm||'31999999'
and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- 당월해지포함
-- and nvl(a.rscs_dh,'29991231') > d.mm||'31'   -- 당월해지제외
AND a.scrbr_no=b.scrbr_no
and a.prdt_cd=c.prdt_cd 
and c.prdt_type_cd in ('34')	
--and a.prdt_cd in ('2018018', '2019001')
and b.SALE_TYPE_CD='1'
and b.scrbr_nm not like '%사업용%'
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh  between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
group by mm , prdt_nm			

select count(*) 
from cmcc02t01 a where   a.svc_open_dh <  '202001'||'31999999'
and nvl(a.rscs_dh,'29991231') > '202001'||'31'   -- 당월해지포함
and a.prdt_cd in  ('2018018')

-- skyA17 가입자수(당월해지포함)
select mm, prdt_nm	, count(*)
from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
( /* 월말 구하기 */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202007'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
where a.svc_open_dh <  d.mm||'31999999'
and nvl(a.rscs_dh,'29991231') > d.mm  -- 당월해지포함 
and a.scrbr_no=b.scrbr_no
and a.prdt_cd=c.prdt_cd 
and B.SALE_TYPE_CD='1'
and b.scrbr_nm not like '%사업용%'	
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and nvl(substr(a.rscs_dh,1.8),'29991231') between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%' )
and c.prdt_cd ='2018010' -- skyA 17			
group by mm, prdt_nm				



-- 월정액가입자수(당월해지포함)
select 
mm, 
--prdt_nm	, 
count(*)
from (
select 
case when c.prdt_type_cd = '34' then 'OTT'
	 when c.prdt_nm like '%MBC%' or c.prdt_nm like '%SBS%' or c.prdt_nm like '%KBS%' or c.prdt_nm like '%지상파%' then '지상파'
	 when c.prdt_nm like '%CJ%'  then '다시보기'
	 when c.prdt_nm like '%JTBC%'  then '다시보기'
	 when c.prdt_nm like '%채널%'  then '다시보기'
	 when c.prdt_nm like '%MBN%'  then '다시보기'
	 when c.prdt_nm like '%애니%'  then '키즈/기타'
	 when c.prdt_nm like '%투니버스%'  then '키즈/기타'
	 when c.prdt_nm like '%PLAYY%'  then '키즈/기타'
	 when c.prdt_nm like '%프라임%'  then '키즈/기타'
	 when c.prdt_nm like '%EBS%'  then '키즈/기타'
	 else '온디멘드'
end 구분,
		a.scrbr_no , c.prdt_nm, mm
		from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
		    ( /* 월말 구하기 */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202007'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
		where a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- 당월해지포함
		and a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and B.SALE_TYPE_CD='1'
		--and c.prdt_nm like '%지상파%'	
		and c.prdt_type_cd in ('25','26')				
        and not exists (select 1 from cmcd01t01 x, mmaj01t01 y where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and nvl(substr(a.rscs_dh,1.8),'29991231') between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%' )
)group by  mm	--, prdt_nm


-- VOD중복제외 이용자수 , 종량제, 월정액, sky17,vod월정액,토핑 중복제외 가입자수 
select  mm 월	, count(distinct scrbr_no) VOD이용자
from (
        (
		-- 월정액가입
		select  --+ parallel (a)
		        mm,  a.scrbr_no 
				from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
				    ( /* 월말 구하기 */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
				where a.svc_open_dh <  d.mm||'31999999'
				and nvl(a.rscs_dh,'29991231') > d.mm||'01' -- 당월해지포함
				and a.scrbr_no=b.scrbr_no
				and a.prdt_cd=c.prdt_cd 
				and B.SALE_TYPE_CD='1'
				and b.scrbr_nm not like '%사업용%'
				and c.prdt_type_cd in ('25','26','34')				
				group by 	mm,  a.scrbr_no		
		)
		union all															
        (
		-- 토핑월말유지수,skyA17
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
		 ( /* 월말 구하기 */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
		where  a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- 당월해지포함
		AND a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and (c.prdt_type_cd in ('34') or c.prdt_cd ='2018010')  -- skyA 17   
		--and a.prdt_cd in ('2018018', '2019001')
		and b.SALE_TYPE_CD='1'
		and b.scrbr_nm not like '%사업용%'
		group by 	mm,  a.scrbr_no						
		)
		union all															
        (
		-- 종량제 이용자
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcb15t01 a, cmcc01t01 b,
		 ( /* 월말 구하기 */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
		where  a.buy_dh  <  d.mm||'31999999'
		and  a.buy_dh  > d.mm||'01' 
		AND a.scrbr_no=b.scrbr_no
		and nvl(a.cncl_yn,'N') = 'N' 
		and b.SALE_TYPE_CD='1'
		and b.scrbr_nm not like '%사업용%'
		group by 	mm,  a.scrbr_no						
		)					
)group by 	mm






--  ppv 주문가능 위성가입자수 
select /*+ parallel (a) */
:mm 월,
'위성' ,
   decode(f.sc_id,null,'제공','차단') ppv_vod제공여부, 	   
   count(distinct a.sc_id) 유지수                 
from cmcc04t01 a, mmda03t01 b,  cmcc01t01 e , 
		(select sc_id, scrbr_no from cmcc39t01 
		where :mm||'31' between stop_fr_dt and nvl(stop_to_dt,:mm||'31')
		and wk_type = '1'
		group by sc_id, scrbr_no)  f               
where a.stb_model_no = b.equip_model_no                     
and b.equip_cl_cd = '1'                     
and :mm||'31' between a.SVC_OPEN_DH and nvl(a.rscs_dh,'29991231') 
and :mm||'31' between e.SVC_OPEN_DH and nvl(e.rscs_dh,'29991231') 
and a.scrbr_no = e.scrbr_no       
and a.scrbr_no = f.scrbr_no(+)
and a.sc_id = f.sc_id(+)         
and e.entr_cl_cd not in ('Y','Z','A','B','C')  -- 비즈, 이동체 제외
and e.recv_mth_cd like '1%'      -- 일반방식만 
and a.MST_FILE_STAT_CD not in ('2','3')  -- 정지제외 
and not exists (select 1 from cmcc06t01 g where a.scrbr_no = g.scrbr_no 
                and :mm||'31' between g.SUSPN_FR_DH and nvl(g.SUSPN_CNCL_DH,'29991231')
				)
group by decode(f.sc_id,null,'제공','차단') 



--  ppv 주문가능 OTS 가입자수 
select /*+ parallel (a) */
:mm 월,
'OTS' 구분,
   decode(f.sc_id,null,'제공','차단') ppv_vod제공여부, 	   
   count(distinct a.scrbr_no) 유지수                 
from ots_scrbr a, ots_equip b,
		(select sc_id, scrbr_no from cmcc39t01 
		where :mm||'31' between stop_fr_dt and nvl(stop_to_dt,:mm||'31')
		and wk_type = '1'
		group by sc_id, scrbr_no)  f               
where :mm||'31' between   substr(a.svc_open_dt,1,6)||'01' and nvl(a.rscs_dt,'29991231') 
and a.scrbr_no = b.scrbr_no
and b.scrbr_no = f.scrbr_no(+)
and b.sc_id = f.sc_id(+)       
--and a.MST_FILE_STAT_CD ='1'  
and a.MST_FILE_STAT_CD not in ('2','3')  -- 정지제외 
and :mm||'31' between a.SVC_OPEN_Dt and nvl(a.rscs_dt,'29991231') 
and :mm||'31' between b.SVC_OPEN_Dt and nvl(b.rscs_dt,'29991231') 
group by decode(f.sc_id,null,'제공','차단') 


-- ppv 상품별 사용자수 , 매출
select 월,구분, 
상품구분,
count(distinct scrbr_no) 사용자수,
sum(상품금액)
from(
SELECT substr(a.recv_dh,1,6) 월, 
	decode(f.scrbr_no ,null,'위성','OTS') 구분,
	substr(chl_nm,1,2) 상품구분,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') 요일, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') 주차,
	b.pgm_nm 상품명, b.pgm_grade 상품등급, c.chl_no 채널번호, c.chl_nm 채널명,
	a.usg_amt 상품금액, a.recv_dh 주문일, e.cd_nm 주문경로, a.scrbr_no
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV정액%' or y.prdt_nm like '%에로티카정액%') 
			  and  (x.mst_file_stat_cd<'4' or x.chg_kind_cd in ('106','107','115','199')
					)
			) y
	   WHERE a.ppv_svc_id = b.ppv_svc_id
	     AND a.brdcst_fr_dh = b.svc_open_dh
	     AND b.chl_no = c.chl_no
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt
	     AND c.vtrl_chl_yn = '1'
	  AND A.CNCL_YN='1'
	  and a.order_path_cd=e.cd(+)
	  and e.cd_cl(+)='CM167'
	  and a.recv_dh between   '20200701' and '20200731'||'999999' 
	  and a.scrbr_no = f.scrbr_no(+)
	  and a.scrbr_no = g.scrbr_no(+)
	  and a.scrbr_no = y.scrbr_no(+)
	  and y.scrbr_no is null
  	  and f.sale_type_cd(+) <> '2'
	  and g.sale_type_cd(+) <> '2'
	  and f.scrbr_no||g.scrbr_no is not null  -- 사업용을 발라내기 위한조건 
)	group by 월 , 구분,
상품구분


-- ppv 사용자수(중복제외) , 매출
select 월,  
--일,구분, 상품구분,
count(distinct scrbr_no) 사용자수,
count(*) 주문수,
sum(상품금액) 종랑제매출
from(
SELECT substr(a.recv_dh,1,6) 월, substr(a.recv_dh,1,8) 일,
	decode(f.scrbr_no ,null,'위성','OTS') 구분,
	substr(chl_nm,1,2) 상품구분,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') 요일, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') 주차,
	b.pgm_nm 상품명, b.pgm_grade 상품등급, c.chl_no 채널번호, c.chl_nm 채널명,
	a.usg_amt 상품금액, a.recv_dh 주문일, e.cd_nm 주문경로, a.scrbr_no
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV정액%' or y.prdt_nm like '%에로티카정액%') 
			  and  (x.mst_file_stat_cd<'4' or x.chg_kind_cd in ('106','107','115','199')
					)
			) y
	   WHERE a.ppv_svc_id = b.ppv_svc_id
	     AND a.brdcst_fr_dh = b.svc_open_dh
	     AND b.chl_no = c.chl_no
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt
	     AND c.vtrl_chl_yn = '1'
	  AND A.CNCL_YN='1'
	  and a.order_path_cd=e.cd(+)
	  and e.cd_cl(+)='CM167'
	  and a.recv_dh between  '20200701' and '20200731'||'999999' 
	  and a.scrbr_no = f.scrbr_no(+)
	  and a.scrbr_no = g.scrbr_no(+)
	  and a.scrbr_no = y.scrbr_no(+)
	  and y.scrbr_no is null
  	  and f.sale_type_cd(+) <> '2'
	  and g.sale_type_cd(+) <> '2'
	  and f.scrbr_no||g.scrbr_no is not null  -- 사업용을 발라내기 위한조건 
)	group by 월 --,구분,상품구분



-- 쿠폰 할인금액 조회  
select 구매월, 
sum(case when COUPON_ISSUE_CD in (71,67,127,134,160) then DISC_AMT end) 리워드쿠폰할인,
sum(case when COUPON_ISSUE_CD in (527,528) then DISC_AMT end) 웰컴쿠폰할인,
sum(case when COUPON_ISSUE_CD = 80 then DISC_AMT end ) sky17극동쿠폰할인,
sum(case when COUPON_ISSUE_CD is null and USG_AMT > 0 and 할인율 in (20,30, 50) then DISC_AMT end ) skyA및콘텐츠프로모션,
sum(case when COUPON_ISSUE_CD not in (80,71,67,127,134,160,208,209,210,527,528) then DISC_AMT end ) 프로모션할인,
sum(case when COUPON_ISSUE_CD in (208,209,210,515,516) then DISC_AMT end ) 고객센터VOC할인,
sum(case when COUPON_ISSUE_CD is null and 할인율 not in (20, 50,30) then DISC_AMT end ) 기타할인,
--sum(USG_AMT) VOD리워드쿠폰매출 , 
sum(DISC_AMT) 총할인금액
from ( 
-- 쿠폰 할인사용내역 
select 
substr(a.buy_dh, 1,6) 구매월, 
substr(a.buy_dh, 1,8) 구매일, 
case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,COUPON_ISSUE_CD,
 a.scrbr_no ,a.sc_id, b.vod_id, b.title,  a.USG_AMT, a.DISC_AMT, PRDT_PRCE, round(a.DISC_AMT/PRDT_PRCE,1)* 100 할인율, 
 decode(a.DISC_AMT,0,'미할인','', '미할인', decode(COUPON_ISSUE_CD,'','skyA할인','쿠폰할인')) 쿠폰할인여부
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between '20200701' and '20200731'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	--and a.scrbr_no='0000737728'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'	
	and buy_type_cd ='1'  -- 종량제 구매건만 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
	--and COUPON_ISSUE_CD is not null
	--and nvl(COUPON_ISSUE_CD,'-') not like 'E%'
    and DISC_AMT > 0
)
group by 구매월
--, 수신기분류	


-- 여기까지 KPI 조회시 사용
========================================================================================
























-- 2018092 상품 극장동시 sky17 상품  청구금액 조회
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,  
a.prdt_cd 상품코드,
b.prdt_nm 상품코드명,
sum(a.invce_amt-a.disc_amt) 매출,
count(a.scrbr_no) 가입자수
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm >= '202003'
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd = '2018092'
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ,  
a.prdt_cd ,
b.prdt_nm	



-- 리워드 쿠폰 PPV 사용내역 
SELECT-- invce_yymm 청구년월, 
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
Sum(disc_amt) 할인금액,
count(distinct a.scrbr_no) 사용자수,
count(*) 사용수
FROM bilng_txn_info a
WHERE unit_svc_cd = 'PPV'
AND disc_adpt_info = '21746'
and a.invce_yymm >= '202003' 
GROUP BY to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm')
ORDER BY 1
;


==================================================================================================
































-- VOD 월정액 매출 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
sum(invce_amt-disc_amt)  VOD월정액청구매출 ,
count(distinct a.scrbr_no)
from CHRG_info a , zzaa02t01 b
where a.invce_yymm >= '201903' and a.invce_yymm <= '201904'
and a.invce_prdt_cd = b.cd
and b.cd_cl = 'BM021'
and cd_nm like '%월정액%'
and (cd_nm like '%VOD%'
	    or  cd_nm like '%지상파%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --조건추가 필요
		or  cd_nm like '%애니맥스%' --조건추가 필요
		or  cd_nm like '%MBN%' --조건추가 필요
		or  cd_nm like '%채널%' --조건추가 필요
		or  cd_nm like '%프라임%' --조건추가 필요
		or  cd_nm like '%애니플러스%' --조건추가 필요
		or  cd_nm like '%EBS%' --조건추가 필요
	   ) 
group by invce_yymm  





--  PPV 월정액 청구매출    2019.3월 수정후                                                     
select /*+ parallel (a) */                                             
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월, 
b.prdt_nm,
sum(invce_amt-disc_amt) PPV월정액청구매출,
count(distinct scrbr_no) 가입자수                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '201302'                                                 
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%정액%'                                                          
group by invce_yymm   ,b.prdt_nm                                                         
order by invce_yymm

--  PPV 월정액 청구매출    2019.3월 수정후                                                     
select /*+ USE_HASH(b a) */                                                    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월, 
b.prdt_nm,
sum(invce_amt-disc_amt) PPV월정액청구매출,
count(distinct scrbr_no) 가입자수                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '201302'                                                 
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%정액%'                                                          
group by invce_yymm   ,b.prdt_nm                                                         
order by invce_yymm

-- VOD 월정액 매출 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a
where invce_yymm = '201903'  
and a.invce_prdt_cd in (
	select cd from zzaa02t01 b  where cd_cl = 'BM021'
	and cd_nm like '%월정액%'
	and ( cd_nm like '%VOD%'
	    or  cd_nm like '%지상파%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --조건추가 필요
		or  cd_nm like '%애니맥스%' --조건추가 필요
		or  cd_nm like '%MBN%' --조건추가 필요
		or  cd_nm like '%채널%' --조건추가 필요
		or  cd_nm like '%프라임%' --조건추가 필요
		or  cd_nm like '%애니플러스%' --조건추가 필요
		or  cd_nm like '%EBS%' --조건추가 필요
	    ) 
)group by invce_yymm                                                                                      



select to_char(BRDCST_FR_DH,'yyyymmddhhhh24miss') from  BILNG_TXN_INFO


select * from  mmag02t01@LN_SCISCM_WEBLOGIC



-- 위성 PPV 청구요금 
select
'위성' 가입구분,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
	case 
    when  to_number(c.chl_no) >= 221  then '레드' 
	else '무비'
	end 채널구분,
c.chl_no,
a.PGM_NM,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  청구금액
from BILNG_TXN_INFO a, CHRG_INFO b, mmab03t01@LN_SCISCM_WEBLOGIC c
where  a.unit_svc_cd = 'PPV' 
and b.unit_svc_cd = 'PPV' 
and b.invce_yymm >= '201904' and a.invce_yymm <= '201904'
and a.invce_yymm >= '201904' and a.invce_yymm <= '201904'
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
and a.ppv_svc_id = c.ppv_svc_id
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss') = c.svc_open_dh
group by a.invce_yymm, c.chl_no, a.PGM_NM
union all
-- OTS PPV 청구요금 
select 
'OTS',
--invce_yymm 청구월, 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--to_char(ADD_MONTHS ( to_date(max(invce_yymm),'YYYYMM') , -1 ),'YYYYMM') , 
	case 
    when  to_number(c.chl_no) >= 221  then '레드' 
	else '무비'
	end 채널구분,
c.chl_no,
a.PGM_NM,
sum(chrg_amnt)	OTS청구매출	
from bilng_txn_info	a	, mmab03t01@LN_SCISCM_MM c
where invce_yymm  >= '201701' and a.invce_yymm <= '201904'
and unit_svc_cd = 'KTPPV'	
and a.ppv_svc_id = c.ppv_svc_id
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss')= c.svc_open_dh
group by invce_yymm	, c.chl_no, a.PGM_NM





-- 위성 PPV 청구요금 , 무비레드 ,채널별 분류 
select  /*+ parallel (a) */
'위성' 구분,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
substr(d.chl_nm,1,2) 상품구분,
c.chl_no,	
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  PPV청구금액
from BILNG_TXN_INFO a, CHRG_INFO b   , mmab03t01@LN_SCISCM_WEBLOGIC c, mmag02t01@LN_SCISCM_WEBLOGIC d
where a.invce_yymm >= '201701'  and a.unit_svc_cd = 'PPV' 
and b.invce_yymm >= '201701'  and b.unit_svc_cd = 'PPV' 
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.ppv_svc_id
AND to_char(a.brdcst_fr_dh,'yyyymmddhh24miss') = c.svc_open_dh
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
group by a.invce_yymm, substr(d.chl_nm,1,2), c.chl_no
union all
-- OTS PPV 청구요금 , 무비레드 ,채널별 분류 
select /*+ parallel (a) */
'OTS' 구분,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
substr(d.chl_nm,1,2) 상품구분,
c.chl_no,	
sum(chrg_amnt)	OTS청구매출	
from bilng_txn_info a	, mmab03t01@LN_SCISCM_WEBLOGIC c, mmag02t01@LN_SCISCM_WEBLOGIC d
where invce_yymm  >= '201701'
and unit_svc_cd = 'KTPPV'	
and a.PPV_SVC_ID = c.ppv_svc_id
AND to_char(a.brdcst_fr_dh,'yyyymmddhh24miss') = c.svc_open_dh
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
group by a.invce_yymm, substr(d.chl_nm,1,2), c.chl_no







--  PPV 월정액 청구매출                                                        
select /*+ USE_HASH(b a) */                                                    
      --invce_yymm 청구월 ,                                                    
      to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,    
      --sum(scrbr_cnt) 사용자수,                                               
      sum(invce_amt-disc_amt) PPV월정액청구매출                                
from  chrg_info a, zzaa02t01 b                                                 
where a.invce_yymm  >= '201702' and invce_yymm <= '201801'                                                
and   a.invce_prdt_cd = cd                                                     
and   cd_cl = 'BM021'                                                          
AND   a.invce_seq_no = 1                                                       
AND   a.invce_type_cd = 'R'                                                    
and   (cd_nm like '%PPV%' or cd_nm like '%에로티카%')                          
and   a.invce_prdt_cd                                                          
      in (                                                                     
      '10132'    ,                                                             
      '10289'    ,                                                             
      '10336'    ,                                                             
      '10344'    ,                                                             
      '10345'    ,                                                             
      '10346'    ,                                                             
      '10347'    ,                                                             
      '10386'    ,                                                             
      '10437'    ,                                                             
      '10462'    ,                                                             
      '10464'    ,                                                             
      '10570'    ,                                                             
      '10571'    ,                                                             
      '10575'    ,                                                             
      '10576'                                                                  
      )  -- 정액제                                                             
group by invce_yymm                                                            
order by invce_yymm                                                            


--  PPV 월정액 청구매출                                                        
select /*+ USE_HASH(b a) */                                                    
      --invce_yymm 청구월 ,   
	  b.cd_nm,                                                  
      to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,    
      --sum(scrbr_cnt) 사용자수,                                               
      sum(invce_amt-disc_amt) PPV월정액청구매출   ,
	  count(a.scrbr_no)                             
from  chrg_info a, zzaa02t01 b                                                 
where a.invce_yymm = '201810'                                                  
and   a.invce_prdt_cd = cd                                                     
and   cd_cl = 'BM021'                                                          
AND   a.invce_seq_no = 1                                                       
AND   a.invce_type_cd = 'R'                                                    
and   (cd_nm like '%PPV%' or cd_nm like '%에로티카%')                          
and   a.invce_prdt_cd                                                          
      in (                                                                     
      '10132'    ,                                                             
      '10289'    ,                                                             
      '10336'    ,                                                             
      '10344'    ,                                                             
      '10345'    ,                                                             
      '10346'    ,                                                             
      '10347'    ,                                                             
      '10386'    ,                                                             
      '10437'    ,                                                             
      '10462'    ,                                                             
      '10464'                                                                                                                             
      )  -- 정액제                                                             
group by invce_yymm   , b.cd_nm                                                         
order by invce_yymm                                                            



--  PPV 월정액 청구매출  
select 
--invce_yymm 청구월 , 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--sum(scrbr_cnt) 사용자수,
sum(invce_amt-disc_amt) PPV월정액청구매출
from chrg_info a, zzaa02t01 b
where invce_yymm = '201811'  and a.invce_prdt_cd = cd
and cd_cl = 'BM021'
AND a.invce_seq_no = 1
AND a.invce_type_cd = 'R'
and (cd_nm like '%PPV%' or cd_nm like '%에로티카%')
and a.invce_prdt_cd 
in (
'10132'    ,
'10289'    ,
'10336'    ,
'10344'    ,
'10345'    ,
'10346'    ,
'10347'    ,
'10386'    ,
'10437'    ,
'10462'    ,
'10464'    ,
'10570'    ,
'10571'    ,
'10575'    ,
'10576'    
)  -- 정액제
group by invce_yymm
order by invce_yymm 






-- ppv 선결제 
select 가입구분, substr(구매일시,1,6) 월 , sum(usg_amt )
from (
SELECT
'PPV' 상품구분,
 a.recv_dh 구매일시 , a.sc_id 스마트카드번호,  b.PPV_SVC_ID vod_id, b.pgm_nm title, 
 --c.chl_no 채널번호, c.chl_nm 채널명,
 PAY_TRNSN_ID PAY_TRNSN_ID,
 g.scrbr_nm 가입계약명,
 decode(f.scrbr_no ,null,'위성','OTS') 가입구분, 
case when g.sale_type_cd = '2' or g.scrbr_nm like '%사업용%' then '사업용' 
end 사업용구분,
 e.cd_nm 주문수단,
a.usg_amt ,
--trunc(PRDT_PRCE*1.1,-1) "가격(부가세포함)", 
--trunc(PREPAY_AMT*1.1,-1) "선결제금액(부가세포함)",
trunc(PREPAY_AMT*1.1,-1) "정산금액(부가세포함)"
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g, cmcc04t01 h, mmda03t01 i
	   WHERE a.ppv_svc_id = b.ppv_svc_id
	     AND a.brdcst_fr_dh = b.svc_open_dh
	     AND b.chl_no = c.chl_no
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt
	     AND c.vtrl_chl_yn = '1'
	  AND A.CNCL_YN='1'
	  and a.order_path_cd=e.cd(+)
	  and e.cd_cl(+)='CM167'
	  and a.recv_dh like '2018%'
	  and a.scrbr_no = f.scrbr_no(+)
	  and a.scrbr_no = g.scrbr_no(+)
	  and ( PAY_TRNSN_ID is not null or order_path_cd like '8%' )
	  --and a.order_path_cd like '8%' 
	  and  PAY_TRNSN_ID is not null
)	  
group by  substr(구매일시,1,6), 가입구분





-- 수신기 유지수 
select substr(dt,1,6) 월, 
 sum(a.MAIN_CNT) 유지수
from mmec50t01 a, mmda03t01 b , zzaa02t01 c
where dt in ('20190831')
and a.equip_model_no = b.equip_model_no
and b.stb_grp_cd = c.cd
and c.cd_cl ='MM083'
--and IP_YN ='0'
--and c.cd_nm not like '%OTS%'
--and CAS_TYPE_CD ='2'
-- AND B.equip_model_nm like '%UHD%'
group by substr(dt,1,6)


-- ppv 사용자수 , 매출
select 월,
구분, 
상품구분,
count(distinct sc_id) 사용자수,
sum(상품금액)
from(
SELECT substr(a.recv_dh,1,6) 월, 
	decode(f.scrbr_no ,null,'위성','OTS') 구분,
	substr(chl_nm,1,2) 상품구분,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') 요일, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') 주차,
	b.pgm_nm 상품명, b.pgm_grade 상품등급, c.chl_no 채널번호, c.chl_nm 채널명,
	a.usg_amt 상품금액, a.recv_dh 주문일, e.cd_nm 주문경로, a.scrbr_no, a.sc_id
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV정액%' or y.prdt_nm like '%에로티카정액%') 
			  and  (x.mst_file_stat_cd<'4' or x.chg_kind_cd in ('106','107','115','199')
					)
			) y
	   WHERE a.ppv_svc_id = b.ppv_svc_id
	     AND a.brdcst_fr_dh = b.svc_open_dh
	     AND b.chl_no = c.chl_no
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt
	     AND c.vtrl_chl_yn = '1'
	  AND A.CNCL_YN='1'
	  and a.order_path_cd=e.cd(+)
	  and e.cd_cl(+)='CM167'
	  and a.recv_dh between   '20190801' and '20190831'||'999999' 
	  and a.scrbr_no = f.scrbr_no(+)
	  and a.scrbr_no = g.scrbr_no(+)
	  and a.scrbr_no = y.scrbr_no(+)
	  and y.scrbr_no is null
  	  and f.sale_type_cd(+) <> '2'
	  and g.sale_type_cd(+) <> '2'
	  and f.scrbr_no||g.scrbr_no is not null  -- 사업용을 발라내기 위한조건 
)	group by 월  , 구분, 상품구분


-- ppv 사용자수 , 
SELECT substr(a.recv_dh,1,6) 월, count(distinct a.scrbr_no)
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g 
	   WHERE a.ppv_svc_id = b.ppv_svc_id 
	     AND a.brdcst_fr_dh = b.svc_open_dh 
	     AND b.chl_no = c.chl_no 
	     AND b.svc_open_dh BETWEEN c.adpt_fr_dt AND c.adpt_to_dt 
	     AND c.vtrl_chl_yn = '1' 
	  AND A.CNCL_YN='1' 
	  and a.order_path_cd=e.cd(+) 
	  and e.cd_cl(+)='CM167' 
	  and a.recv_dh between  '20190801' and '20190831'||'999999' 
	  and a.scrbr_no = f.scrbr_no(+) 
	  and a.scrbr_no = g.scrbr_no(+) 
  	  and f.sale_type_cd(+) <> '2' 
	  and g.sale_type_cd(+) <> '2' 
	  and f.scrbr_no||g.scrbr_no is not null  
	  group by  substr(a.recv_dh,1,6)
	  

-- VOD 월정액 매출, 시군구별 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
d.do_nm, sigun_nm,
cd_nm,
sum(invce_amt-disc_amt)  VOD월정액청구매출 ,
count(distinct a.scrbr_no) 가입자수
from CHRG_info a , zzaa02t01 b, cmcc01t01 c, 
(select zip_cd, min(do_nm) do_nm,min(sigun_nm) sigun_nm, min(TOWN_NM) TOWN_NM, min(DELVR_PLCE_RI_NM)DELVR_PLCE_RI_NM
		       from zzaa03t01@LN_SCISCM_MM 
			   where do_nm in ('서울','경기') 
			   and sigun_nm in ('마포구','용산구','서대문구','은평구','중구', '영등포구','종로구','성동구', '고양시 덕양구')
		       group by zip_cd) d 
where invce_yymm = '201812'  
and a.invce_prdt_cd = b.cd
and b.cd_cl = 'BM021'
and cd_nm like '%월정액%'
and (cd_nm like '%VOD%'
	    or  cd_nm like '%지상파%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --조건추가 필요
		or  cd_nm like '%애니맥스%' --조건추가 필요
		or  cd_nm like '%MBN%' --조건추가 필요
		or  cd_nm like '%채널%' --조건추가 필요
		or  cd_nm like '%프라임%' --조건추가 필요
		or  cd_nm like '%애니플러스%' --조건추가 필요
		or  cd_nm like '%EBS%' --조건추가 필요
	   ) 
and a.scrbr_no = c.scrbr_no
and c.INSTAL_PLCE_ZIP_CD = d.zip_cd	   
group by invce_yymm, d.do_nm, sigun_nm	, cd_nm  
having sum(invce_amt-disc_amt) > 0


select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201905'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')


-- 수신기별 월정액 청구매출 조회 
-- 요금디비 조회, VOD 월정액 청구매출 조회  상품별, 가입자분석, 일부 오차 있음 총액보다 작게 나옴 
SELECT/*+ use_hash (c a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--equip_model_no, equip_model_nm,
	case
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,
Sum(invce_amt)-Sum(disc_amt) 수신기별월정액매출 ,
count(c.scrbr_no)
FROM chrg_info a,  cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, MMAA04T01 g, prdt_fix_chrg h
WHERE invce_yymm = '201905' -- 청구월 
And invce_type_cd = 'R'  --추가
And invce_seq_no = 1 --추가
and a.chrg_item_cd = h.chrg_item_cd
and h.prdt_cd = g.prdt_cd
and g.prdt_type_cd in ('25','26')
and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and a.scrbr_no = e.scrbr_no
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < invce_yymm  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > invce_yymm  -- 수신기교체자 주문일시고려
GROUP BY 
invce_yymm,--equip_model_no, equip_model_nm,
case
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end

	

-- 수신기별 월정액 청구매출 조회 
-- 요금디비 조회, VOD 월정액 청구매출 조회  상품별, 가입자분석, 일부 오차 있음 총액보다 작게 나옴 
select 
기준월,
수신기분류,
case when 연령대 between '0' and '99' then 
	case when 연령대 between 0 and 29  then '20대이하'
	     when 연령대 between 30 and 39  then '30대'
	     when 연령대 between 40 and 49  then '40대' 
	     when 연령대 between 50 and 59  then '50대'
	     when 연령대 between 60 and 69 then '60대'
	     when 연령대 >= 70 then '70세이상'
	 else  '-'
	 end
 else  '-'	  
end 연령대,
sum(수신기별월정액매출),
sum(가입자수)
from (
SELECT/*+ use_hash (c a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--equip_model_no, equip_model_nm,
	case
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,
DECODE (length(d.JUMIN_BIZ_NO),7,                                                                         
	to_char(trunc((to_number('2019')-                                                                 
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2))))))))))))))))))))
	,'--') 	,
	DECODE (length(d.JUMIN_BIZ_NO),7,                                                                         
	to_char(trunc((to_number('2019')-                                                                 
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2))))))))))))))))))/10)*10)
	,'--') 연령대,	
Sum(invce_amt)-Sum(disc_amt) 수신기별월정액매출 ,
count(c.scrbr_no) 가입자수
FROM chrg_info a,  cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, MMAA04T01 g, prdt_fix_chrg h
WHERE invce_yymm = '201905' -- 청구월 
And invce_type_cd = 'R'  --추가
And invce_seq_no = 1 --추가
and a.chrg_item_cd = h.chrg_item_cd
and h.prdt_cd = g.prdt_cd
and g.prdt_type_cd in ('25','26')
and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and a.scrbr_no = e.scrbr_no
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < invce_yymm  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > invce_yymm  -- 수신기교체자 주문일시고려
GROUP BY 
invce_yymm,--equip_model_no, equip_model_nm,
case
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end,
DECODE (length(d.JUMIN_BIZ_NO),7,                                                                         
	to_char(trunc((to_number('2019')-                                                                 
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2))))))))))))))))))))
	,'--'),
	DECODE (length(d.JUMIN_BIZ_NO),7,                                                                         
	to_char(trunc((to_number('2019')-                                                                 
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2),                        
	(DECODE(SUBSTR(d.JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(d.JUMIN_BIZ_NO, 1, 2))))))))))))))))))/10)*10)
	,'--')
)group by 
기준월,
수신기분류,
case when 연령대 between '0' and '99' then 
	case when 연령대 between 0 and 29  then '20대이하'
	     when 연령대 between 30 and 39  then '30대'
	     when 연령대 between 40 and 49  then '40대' 
	     when 연령대 between 50 and 59  then '50대'
	     when 연령대 between 60 and 69 then '60대'
	     when 연령대 >= 70 then '70세이상'
	 else  '-'
	 end
 else  '-'	  
end

	


-- 2018092 상품 극장동시 sky17 상품  청구금액 조회
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,  
a.prdt_cd 상품코드,
b.prdt_nm 상품코드명,
sum(a.invce_amt-a.disc_amt) 매출,
count(a.scrbr_no) 가입자수
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm >= '201801'
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd = '2018092'
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ,  
a.prdt_cd ,
b.prdt_nm	







-- VOD 선결제 매출 , 카드, 휴대폰, 포인트  , 남석우 요청                                                     
select   
substr(구매일시,1,6) 월,수신기분류, 결제수단, sum(PREPAY_AMT)+ sum(pnt_amt) 선결제금액, sum(usg_amt) 매출                                                           
from (                                                                                         
select                                                                                         
b.scrbr_no 가입계약번호, b.scrbr_nm 가입계약명,a.sc_id ,                                         
usg_amt,PREPAY_AMT ,    pnt_amt,                                                                               
buy_dh 구매일시, d.cd_nm 결제수단,                                                             
a.vod_id,c.title, main_cate_nm , sub_cate_nm , CONTENTS_CATE, CP_NM, DISTR_CMPY, PRDT_CMPY ,
case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
end 수신기분류    
from cmcb15t01 a, cmcc01t01 b, mmab06t01 c, zzaa02t01 d ,  cmcc04t01 e, mmda03t01 f                                     
where  buy_dh > '201811'                                                                   
--and af_invce_yn ='N'                                                                         
and a.scrbr_no = b.scrbr_no                                                                    
and (a.prepay_amt <> 0 or pnt_amt <> 0 )                                                                          
and a.vod_id = c.vod_id                                                                        
and a.PAY_MTH_CD = d.cd                                                                        
and d.cd_cl ='CM448'                                                                           
and nvl(a.cncl_yn,'N') = 'N' 
and a.scrbr_no = e.scrbr_no
and a.sc_id = e.sc_id
and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려                                                                 
) group by substr(구매일시,1,6) ,수신기분류, 결제수단
    

	
-- 상품별 위성 PPV 청구요금
select 
'위성' 구분,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
substr(d.chl_nm,1,2), d.chl_no,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  위성PPV청구금액, 
count(distinct a.scrbr_no) 이용자수, count(*) 주문수
from BILNG_TXN_INFO a, CHRG_INFO b , mmab03t01@LN_SCISCM_MM c, mmag02t01@LN_SCISCM_weblogic d
where a.invce_yymm  >= '201902' and a.invce_yymm <= '201907'
and a.unit_svc_cd = 'PPV' 
and b.invce_yymm  >= '201902' and b.invce_yymm <= '201907'
and b.unit_svc_cd = 'PPV' 
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss') = c.svc_open_dh 
and a.PPV_SVC_ID = c.ppv_svc_id
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
-- and invce_amt > 0
group by a.invce_yymm, substr(d.chl_nm,1,2),  d.chl_no


-- 상품별 OTS PPV 청구요금 
select 
'OTS' 구분,
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
substr(d.chl_nm,1,2), d.chl_no,
sum(chrg_amnt)	OTS청구매출	,
count(distinct a.scrbr_no) 이용자수, count(*) 주문수
from bilng_txn_info	a	, mmab03t01@LN_SCISCM_MM c, mmag02t01@LN_SCISCM_weblogic d
where invce_yymm  >= '201902' and a.invce_yymm <= '201907'
and unit_svc_cd = 'KTPPV'	
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss') = c.svc_open_dh 
and a.PPV_SVC_ID = c.ppv_svc_id
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
group by  a.invce_yymm, substr(d.chl_nm,1,2),  d.chl_no

-- VOD 카테고리별종량제청구금액
select 
-- a.invce_yymm 청구월,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
c.CONTENTS_CATE,
--count(distinct a.scrbr_no)  사용자수,
--sum(chrg_amnt) 금액,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구할인금액,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구금액  
from BILNG_TXN_INFO a, CHRG_INFO b, mmab06t01@LN_SCISCM_MM c  
where a.invce_yymm >= '201802' and a.invce_yymm <= '201802'
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '201802' and a.invce_yymm <= '201802'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.vod_id(+)
group by a.invce_yymm, c.CONTENTS_CATE


-- 방송시장경쟁상황평가 자료제출 cp분류별 매출 
select
--CONTENTS_CATE,  b.cp_nm,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end 콘텐츠분류,
 --      main_cate_nm,
	sum(usg_amt)
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between  '20190101' and '20191231'||'999999'
	--and a.vod_id ='C181227V795004'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
--and a.scrbr_no='0007936271'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'	
	and buy_type_cd ='1'  -- 종량제 구매건만 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
	group by --CONTENTS_CATE, b.cp_nm 				
	case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end


-- 방송시장경쟁상황평가 자료제출 cp분류별 청구매출  
select 
-- a.invce_yymm 청구월,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end 콘텐츠분류,
--c.CONTENTS_CATE,
--count(distinct a.scrbr_no)  사용자수,
--sum(chrg_amnt) 금액,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구할인금액,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) 청구금액  
from BILNG_TXN_INFO a, CHRG_INFO b, mmab06t01@LN_SCISCM_MM c  
where a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.vod_id(+)
group by a.invce_yymm, -- c.CONTENTS_CATE
case when CONTENTS_CATE in ('지상파 다시보기') then '지상파'
     when CONTENTS_CATE in ('영화', '성인영화') then '영화'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'CJ ENM' then 'CJ 계열'
	 when CONTENTS_CATE in ('TV 다시보기') and cp_nm in 'JTBC' then 'JTBC 계열'
	 else '기타'
end



-- VOD 월정액 매출, 2019.3월 수정후 
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
b.prdt_nm,
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201907'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm  , b.prdt_nm


-- 방송시장경쟁상황평가 자료제출 cp분류별 월정액 매출 
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%지상파%' then '지상파'
	 when prdt_nm like '%CJ%' or prdt_nm like '%투니버스%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'	 
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%캐치온%' then '영화'
	 else '기타'
end 구분,
b.prdt_nm 월정액상품명,
sum(invce_amt-disc_amt)  VOD월정액청구매출 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm ,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%지상파%' then '지상파'
	 when prdt_nm like '%CJ%' or prdt_nm like '%투니버스%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'	 
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%캐치온%' then '영화'
	 else '기타'
end , 
b.prdt_nm
order by 3,4
