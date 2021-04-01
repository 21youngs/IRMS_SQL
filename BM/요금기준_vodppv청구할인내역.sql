
-- 1. VOD 청구 기준 정산자료 생성, 사업용제외, 쿠폰사용 포함 
select c.scrbr_no 가입계약번호, c.scrbr_nm 가입계약명, e.sc_id,
chrg_amnt 청구기준금액, 
trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0)))  청구할인금액,
chrg_amnt - trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))) 최종청구금액,
e.prdt_prce 판매가,
e.usg_amt 매출,
e.disc_amt 쿠폰할인액,
to_char(SVC_USE_DH,'yyyymmddhh24miss') 구매일시, 
'청구서' 결제수단,
--a.BRDCST_FR_DH 시청일시,
--pgm_nm , 
a.PPV_SVC_ID vod_id ,
d.title, 
main_cate_nm , sub_cate_nm , CONTENTS_CATE,  CP_NM, DISTR_CMPY, PRDT_CMPY
--,a.*, chrg_amnt * (b.disc_amt/invce_amt)  청구할인금액  
from BILNG_TXN_INFO a, CHRG_INFO b  , cmcc01t01 c , mmab06t01@LN_SCISCM_MM d , cmcb15t01@LN_SCISCM_CM  e
where a.invce_yymm = :mm and a.unit_svc_cd = 'VOD' -- 청구월 
and b.invce_yymm = :mm and b.unit_svc_cd = 'VOD'    -- 청구월 
--and a.scrbr_no ='0002174272'
and a.scrbr_no = b.scrbr_no  
and a.scrbr_no = c.scrbr_no
and a.PPV_SVC_ID = d.vod_id
and a.SCRBR_NO = e.scrbr_no
and a.PPV_SVC_ID = e.vod_id
and a.svc_no = e.sc_id
and to_char(a.svc_use_dh,'yyyymmddhh24miss') = e.buy_dh
and c.sale_type_cd = '1'
and c.scrbr_nm not like '%사업용%'	
and e.af_invce_yn ='Y'
and e.prdt_prce <> 0 -- 판매가 0원이상 
and trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))) > 0
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and e.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)	

select * from cmcb06t01@LN_SCISCM_CM					

select *
from BILNG_TXN_INFO a
where  a.invce_yymm = :mm and a.unit_svc_cd = 'PPV'					


-- 위성 PPV 청구할인 
select
--to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  위성PPV청구금액
c.scrbr_no 가입계약번호, c.scrbr_nm 가입계약명, e.sc_id,
sale_cost, 
disc_adpt_info,
chrg_amnt 청구기준금액, 
trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0)))  청구할인금액,
chrg_amnt - trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))) 최종청구금액,
e.usg_amt 매출,
e.disc_amt 쿠폰할인액,
to_char(SVC_USE_DH,'yyyymmddhh24miss') 구매일시, 
e.recv_dh,
'청구서' 결제수단,
--a.BRDCST_FR_DH 시청일시,
--pgm_nm , 
a.PPV_SVC_ID vod_id ,
d.pgm_nm ,
e.af_invce_yn
from BILNG_TXN_INFO a, CHRG_INFO b,  cmcc01t01 c , mmab03t01@LN_SCISCM_MM d , cmcb06t01@LN_SCISCM_CM  e
where  a.invce_yymm = :mm and a.unit_svc_cd = 'PPV' -- 청구월 
and b.invce_yymm = :mm and b.unit_svc_cd = 'PPV'    -- 청구월 
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm				
and a.scrbr_no = c.scrbr_no
and a.ppv_svc_id = d.ppv_svc_id
AND to_char(a.brdcst_fr_dh,'yyyymmddhh24miss') = d.svc_open_dh
and a.SCRBR_NO = e.scrbr_no
and a.PPV_SVC_ID = e.ppv_svc_id
and a.svc_no = e.sc_id
--and to_char(a.svc_use_dh,'yyyymmddhh24miss') = e.recv_dh
and c.sale_type_cd = '1'
and c.scrbr_nm not like '%사업용%'	
-- and e.af_invce_yn ='Y'
and trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))) > 0
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and e.recv_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
and not exists (
			   select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			   where x.prdt_cd=y.prdt_cd 
			   and  (y.prdt_nm like '%PPV정액%' or y.prdt_nm like '%에로티카정액%') 
			   and  (x.mst_file_stat_cd<'4' or x.chg_kind_cd in ('106','107','115','199'))
			   and a.scrbr_no = x.scrbr_no
			   and e.recv_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
			)

					
select *
from bilng_txn_info	a	
where invce_yymm  >= '201908' and a.invce_yymm <= '201908'
and unit_svc_cd = 'KTPPV'	
and nvl(a.disc_amt,0) > 0



-- OTS  PPV 청구할인 
select
--to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') 기준월,
--round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  위성PPV청구금액
--c.scrbr_no 가입계약번호, c.scrbr_nm 가입계약명, 
e.sc_id,
sale_cost, 
disc_adpt_info,
chrg_amnt 청구기준금액, 
nvl(a.disc_amt,0) disc_amt,
--trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0)))  청구할인금액,
--chrg_amnt - trunc(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))) 최종청구금액,
e.usg_amt 매출,
e.disc_amt 쿠폰할인액,
to_char(SVC_USE_DH,'yyyymmddhh24miss') 구매일시, 
e.recv_dh,
'청구서' 결제수단,
--a.BRDCST_FR_DH 시청일시,
--pgm_nm , 
a.PPV_SVC_ID ,
a.pgm_nm ,
e.af_invce_yn
from BILNG_TXN_INFO a,   mmab03t01@LN_SCISCM_MM d , cmcb06t01@LN_SCISCM_CM  e
where  a.invce_yymm = :mm and a.unit_svc_cd = 'KTPPV' -- 청구월 
and a.ppv_svc_id = d.ppv_svc_id
AND to_char(a.brdcst_fr_dh,'yyyymmddhh24miss') = d.svc_open_dh
and a.SCRBR_NO = e.scrbr_no
and a.PPV_SVC_ID = e.ppv_svc_id
--and a.svc_no = e.sc_id
--and to_char(a.svc_use_dh,'yyyymmddhh24miss') = e.recv_dh
-- and e.af_invce_yn ='Y'
and nvl(a.disc_amt,0) > 0

and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and e.recv_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
and not exists (
			   select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			   where x.prdt_cd=y.prdt_cd 
			   and  (y.prdt_nm like '%PPV정액%' or y.prdt_nm like '%에로티카정액%') 
			   and  (x.mst_file_stat_cd<'4' or x.chg_kind_cd in ('106','107','115','199'))
			   and a.scrbr_no = x.scrbr_no
			   and e.recv_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
			)
										