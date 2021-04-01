
	
-- ppvod 월별 미납금액  
select a.invce_yymm, 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') 청구상품명 ,
sum(a.NET_INVCE_AMT) 미납액  
from invce_cnfm_info a, invce_item_info b  
where 1=1  
and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
and a.invce_yymm between '201901' and '201907'    -- 특정 청구월 기간 설정  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 


-- ppvvod 미납이력(조정추가)   
select   
a.invce_yymm,  
a.scrbr_no , sum(a.NET_INVCE_AMT) avg_unpaid  , Sum(tot_adjst_amt) adjst_amt,  
Decode(b.invce_grp_cd,'120','PPV','125','VOD') 청구상품명   
from invce_cnfm_info a, invce_item_info b    
where  1= 1 
-- and  a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출    
and a.invce_yymm = '201906'     
and b.invce_grp_cd IN ('120','125')   
and a.open_item_cd  = b.open_item_cd    
--and a.scrbr_no ='0010168607'  
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm  
 having Sum(tot_adjst_amt) > 0 -- 조정금액   

	
	
	
-- ppvvod 미납이력 
select 
a.invce_yymm,
a.scrbr_no , sum(a.NET_INVCE_AMT) avg_unpaid  , 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') 청구상품명 
from invce_cnfm_info a, invce_item_info b  
where  a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
and a.invce_yymm >= '201906'   
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
and a.scrbr_no ='0012138009'
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 	



-- VOD 미납결과 와 예상 필터링 비교 
select x.roylt_type_cd 구분, x.setl_dm 정산월, x.scrbr_no 가계번호,z.INVCE_ACCT_NO 청구계정, 
z.청구금액*1.1 미납예상정산필터링금액, y.미납금 실미납금액, z.구매취소처리금액 실취소금액,  y.조정금 실조정금액,
nvl(y.미납금,0) +  nvl(z.구매취소처리금액,0) + nvl(y.조정금,0) 실미납총액
from (
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR
where setl_dm ='202006'  -- 청구월(정산월) 
and roylt_type_cd ='VOD'
) x,   
(
-- ppvod 미납이력 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) 미납금  ,  Sum(tot_adjst_amt) 조정금  
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
        and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		--and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출, 조정내역 포함시 주석처리    
		and a.invce_yymm = '202006'    -- 청구월(정산월) 
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		--and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		--                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
		  or  Sum(tot_adjst_amt) > 0
) y,
(
   select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, c.INVCE_ACCT_NO,
   count(*) paycnt, 
   sum(a.AF_INVCE_AMT) 청구금액, 
   sum(decode(a.cncl_yn,'Y',a.usg_amt)) 구매취소처리금액
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between '202005'||'01' and '202005'||'99999999'  -- 구매월, 정산월 +1 ,청구월 +1
		--and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm, c.INVCE_ACCT_NO
) z
where x.scrbr_no = y.scrbr_no(+)	
and x.scrbr_no = z.scrbr_no(+)	


-- PPV  미납결과 와 예상 필터링 비교 
select x.roylt_type_cd 구분,x.setl_dm 정산월, x.scrbr_no 가계번호,z.INVCE_ACCT_NO 청구번호, 
nvl(z.payamt*1.1,0) 미납예상정산필터링금액,  y.tot_unpaid 실미납금액, z.구매취소처리금액 실취소금액, y.adjst_amt 실조정금액,
nvl(y.tot_unpaid,0) +  nvl(z.구매취소처리금액,0) + nvl(y.adjst_amt,0) 실미납총액
from (
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR
where setl_dm ='202006' -- 청구월(정산월) 
and roylt_type_cd ='PPV'
) x,   
(
-- ppvod 미납이력 
		select a.scrbr_no ,  sum(a.NET_INVCE_AMT) tot_unpaid    , Sum(tot_adjst_amt) adjst_amt  
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
        and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출, 조정내역 포함시 주석처리  
		and a.invce_yymm = '202006'    -- 청구월(정산월) 
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		--and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		--                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
		   or  Sum(tot_adjst_amt) > 0
) y,
(
      select  a.scrbr_no,c.INVCE_ACCT_NO, c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt, sum(decode(CNCL_YN,'0',a.usg_amt)) 구매취소처리금액
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  '202005'||'01' and '202005'||'99999999' -- 구매월, 정산월 +1 ,청구월 +1
		--and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		--and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no	,c.INVCE_ACCT_NO, c.svc_open_dh, c.scrbr_nm
) z
where x.scrbr_no = y.scrbr_no(+)		
and x.scrbr_no = z.scrbr_no(+)			
order by nvl(y.tot_unpaid,0) desc,  nvl(z.payamt,0) desc 

	
-- VOD미납예상 필터링 	
select * 
from (
	select 
	'VOD정산예외' "구분",
	:mm 구매월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt 당월구매수 , x.payamt 당월구매금액 ,  x.payamt*1.1 당월정산기준금액,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)  초과요금증감배수, 
	y.avg_paycnt 월평균구매수 , 	y.avg_payamt 월평균구매금액 , tot_unpaid 전월미납금  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'  -- 사용월기준
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.AF_INVCE_AMT)/3 , 0)avg_payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력. 미납+ 조정금액 
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		--and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
		      or  Sum(tot_adjst_amt) > 0 -- 조정금액 있는것 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(전월미납금,0)  > 10000 and 당월구매금액 > 10000 )-- 미납액 1만원 이상, 청구액 1만원 이상 
    or (개통경과개월 <= 1 and 당월구매금액 > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and 당월구매금액 > 월평균구매금액 * 5 and 당월구매금액 > 100000) -- 평균이용보다 5배 이용, 10만원 이상 
	);

   
   
-- PPV미납예상 필터링 	
select * 
from (
	select  
	'PPV정산예외' "구분",
	OTS구분,
	:mm 구매월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt 당월구매건수 , x.payamt 당월구매금액 ,  x.payamt*1.1 당월정산기준금액,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)  초과요금증감배수, 
	y.avg_paycnt 월평균구매수 , 	y.avg_payamt 월평균구매액 , tot_unpaid 전월미납금  
	from (	
		select  
            decode(d.scrbr_no ,null,'위성','OTS') OTS구분,
            a.scrbr_no,c.scrbr_nm, 
            decode(d.scrbr_no ,null,c.svc_open_dh,d.svc_open_dt) svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
            from cmcb06t01 a, cmcc01t01 c, ots_scrbr d 
            where a.recv_dh between  :mm||'01' and :mm||'99999999'
            and CNCL_YN='1'
            and a.scrbr_no = c.scrbr_no(+)
            and a.scrbr_no = d.scrbr_no(+)
            and c.sale_type_cd(+) <> '2'   
            and d.sale_type_cd(+) <> '2' 
            and c.scrbr_no||d.scrbr_no is not null 
            group by decode(d.scrbr_no ,null,'위성','OTS') , 
            a.scrbr_no	, decode(d.scrbr_no ,null,c.svc_open_dh,d.svc_open_dt), c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.usg_amt)/3 , 0) avg_payamt
		from cmcb06t01 a
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력. 과거3개월  
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
		  or  Sum(tot_adjst_amt) > 0 -- 조정금액 있는것 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
--and OTS구분 = 'OTS'
    and
	(  (nvl(전월미납금,0)  > 0 and 전월미납금 > 10000 and 당월구매금액 > 10000)-- 미납액 1만원 이상, 구매금액 1만원 이상
    or (개통경과개월 <= 1 and 당월구매금액 > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and 당월구매금액 > 월평균구매액 * 20 and 당월구매금액 > 50000) -- 평균이용보다 20배 이용, 5만원 이상 
	)
  
     


-- VOD 미납 예상 검증 
select xx.*,' ', yy.* from (
-- ppvvod 미납이력 
select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
from invce_cnfm_info a, invce_item_info b  
where 1= 1 
and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm')   -- 특정 청구월 기간 설정  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by a.invce_yymm, a.scrbr_no
having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
) xx, (
-- VOD미납예상 필터링 	
select * 
from (
	select 
	'VOD정산예외',
	:mm 기준월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt , x.payamt , x.payamt*1.1 정산금액,
	y.avg_paycnt , 	y.avg_payamt ,
	round(x.payamt/nullif(y.avg_payamt,0),1)*100  초과율,
	tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.AF_INVCE_AMT)/3 , 0)avg_payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		and a.pay_full_stat_cd = 'O'     -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'   -- 당월 청구금액 제외  
		and a.invce_yymm between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 10000 and payamt > 0)-- 미납액 1만원 이상
    or (개통경과개월 <= 1 and payamt > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and payamt > avg_payamt * 5 and payamt > 100000) -- 평균이용보다 5배 이용, 10만원 이상 
	)
) yy
where xx.scrbr_no(+) = yy.scrbr_no 
   
   

-- PPV 미납 예상 검증 
select xx.*,' ', yy.* from (
	-- ppvvod 미납이력 
	select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
	from invce_cnfm_info a, invce_item_info b  
	where 1= 1 
	and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
	and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
	--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
	and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm') -- 청구월기준이므로 +1 개월 
	and b.invce_grp_cd IN ('120','125') 
	and a.open_item_cd  = b.open_item_cd  
	group by a.invce_yymm, a.scrbr_no
	having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
) xx, 
(
-- PPV미납예상 필터링 	
select * 
from (
	select  
	'PPV정산예외' "구분",
	:mm 구매월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt 구매건수 , x.payamt 구매금액 ,  x.payamt*1.1 정산기준금액,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100   초과사용율, 
	y.avg_paycnt 월평균구매수 , 	y.avg_payamt 월평균구매액 , tot_unpaid 미납금  
	from (	
		select  
            decode(d.scrbr_no ,null,'위성','OTS') 구분,
            a.scrbr_no,c.scrbr_nm, 
            decode(d.scrbr_no ,null,c.svc_open_dh,d.svc_open_dt) svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
            from cmcb06t01 a, cmcc01t01 c, ots_scrbr d 
            where a.recv_dh between  :mm||'01' and :mm||'99999999'
            and CNCL_YN='1'
            and a.scrbr_no = c.scrbr_no(+)
            and a.scrbr_no = d.scrbr_no(+)
            and c.sale_type_cd(+) <> '2'   
            and d.sale_type_cd(+) <> '2' 
            and c.scrbr_no||d.scrbr_no is not null 
            group by decode(d.scrbr_no ,null,'위성','OTS') , 
            a.scrbr_no	, decode(d.scrbr_no ,null,c.svc_open_dh,d.svc_open_dt), c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.usg_amt)/3 , 0) avg_payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력. 과거3개월  
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
		  or  Sum(tot_adjst_amt) > 0 -- 조정금액 있는것 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(미납금,0)  > 0 and 미납금 > 10000 and 구매금액 > 10000)-- 미납액 1만원 이상, 구매금액 1만원 이상
    or (개통경과개월 <= 1 and 구매금액 > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and 구매금액 > 월평균구매액 * 20 and 구매금액 > 50000) -- 평균이용보다 20배 이용, 5만원 이상 
	)  
) yy
where xx.scrbr_no(+) = yy.scrbr_no



-- PPV 미납자 패턴
select xx.*, yy.* from (
	-- ppvvod 미납이력 
	select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
	from invce_cnfm_info a, invce_item_info b  
	where 1= 1 
	and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
	and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
	--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
	and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm')
	and b.invce_grp_cd IN ('120','125') 
	and a.open_item_cd  = b.open_item_cd  
	group by a.invce_yymm, a.scrbr_no
	having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
) xx, (
-- PPV미납예상 필터링 	
select * 
from (
	select  
	'PPV정산예외',
	:mm 기준월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt , x.payamt , 
	round(x.payamt/nullif(y.avg_payamt,0),1)*100  초과율, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  :mm||'01' and :mm||'99999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/6,1) avg_paycnt, round(sum(a.usg_amt)/6 , 0)avg_payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-6),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력. 과거3개월  
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-6),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 5000 and payamt > 0)-- 미납액 0원 이상
    or (개통경과개월 <= 1 and payamt > 30000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 --and payamt > avg_payamt * 3 
	                     and payamt > 50000) -- 평균이용보다 5배 이용, 10만원 이상 
	)
) yy
where xx.scrbr_no = yy.scrbr_no(+)


-- ppvod 미납이력 
select a.scrbr_no 가계번호, sum(a.NET_INVCE_AMT) avg_unpaid  , 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') 청구상품명 
from invce_cnfm_info a, invce_item_info b  
where 1=1  
and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
and a.invce_yymm between '201902' and '201904'    -- 특정 청구월 기간 설정  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 


  
-- PPV미납검증대상 조회 
select * 
from (
	select  
	'PPV정산예외' "구분",
	:mm 기준월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt , x.payamt ,  x.payamt*1.1 정산기준금액,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100   초과사용율, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  :mm||'01' and :mm||'99999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		and a.scrbr_no in ('0009578009')
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.usg_amt)/3 , 0)avg_payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력. 과거3개월  
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 5000 and payamt > 0)-- 미납액 0원 이상
    or (개통경과개월 <= 1 and payamt > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and payamt > avg_payamt * 30 and payamt > 50000) -- 평균이용보다 5배 이용, 10만원 이상 
	)
	


-- VOD미납검증대상 조회 
select * 
from (
	select 
	'VOD정산예외' "구분",
	:mm 기준월,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) 개통월 , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) 개통경과개월,
	x.paycnt , x.payamt ,  x.payamt*1.1 정산기준금액,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100  초과사용율, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		and a.scrbr_no in (
		'0011329768',
		'0010612051',
		'0007716945',
		'0008622162',
		'0010836412',
		'0009254793'
		)
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.AF_INVCE_AMT)/3 , 0)avg_payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%사업용%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod 미납이력 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		and a.pay_full_stat_cd = 'O'    -- 미납금이 있는 것만 추출  
		--and a.invce_yymm <> '201905'    -- 당월 청구금액 제외  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- 특정 청구월 기간 설정  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --미납금액이 있는 것만 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 10000 and payamt > 0)-- 미납액 1만원 이상
    or (개통경과개월 <= 1 and payamt > 100000 )--  처음부터 10 만원이상 
    or (개통경과개월 > 1 and payamt > avg_payamt * 5 and payamt > 100000) -- 평균이용보다 5배 이용, 10만원 이상 
	)
	

-- 정산예외 처리 테이블 
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR  --- / 판권료정산제외가계정보 	

