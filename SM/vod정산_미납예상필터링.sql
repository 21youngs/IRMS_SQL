
	
-- ppvod ���� �̳��ݾ�  
select a.invce_yymm, 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') û����ǰ�� ,
sum(a.NET_INVCE_AMT) �̳���  
from invce_cnfm_info a, invce_item_info b  
where 1=1  
and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
and a.invce_yymm between '201901' and '201907'    -- Ư�� û���� �Ⱓ ����  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 


-- ppvvod �̳��̷�(�����߰�)   
select   
a.invce_yymm,  
a.scrbr_no , sum(a.NET_INVCE_AMT) avg_unpaid  , Sum(tot_adjst_amt) adjst_amt,  
Decode(b.invce_grp_cd,'120','PPV','125','VOD') û����ǰ��   
from invce_cnfm_info a, invce_item_info b    
where  1= 1 
-- and  a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����    
and a.invce_yymm = '201906'     
and b.invce_grp_cd IN ('120','125')   
and a.open_item_cd  = b.open_item_cd    
--and a.scrbr_no ='0010168607'  
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm  
 having Sum(tot_adjst_amt) > 0 -- �����ݾ�   

	
	
	
-- ppvvod �̳��̷� 
select 
a.invce_yymm,
a.scrbr_no , sum(a.NET_INVCE_AMT) avg_unpaid  , 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') û����ǰ�� 
from invce_cnfm_info a, invce_item_info b  
where  a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
and a.invce_yymm >= '201906'   
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
and a.scrbr_no ='0012138009'
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 	



-- VOD �̳���� �� ���� ���͸� �� 
select x.roylt_type_cd ����, x.setl_dm �����, x.scrbr_no �����ȣ,z.INVCE_ACCT_NO û������, 
z.û���ݾ�*1.1 �̳������������͸��ݾ�, y.�̳��� �ǹ̳��ݾ�, z.�������ó���ݾ� ����ұݾ�,  y.������ �������ݾ�,
nvl(y.�̳���,0) +  nvl(z.�������ó���ݾ�,0) + nvl(y.������,0) �ǹ̳��Ѿ�
from (
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR
where setl_dm ='202006'  -- û����(�����) 
and roylt_type_cd ='VOD'
) x,   
(
-- ppvod �̳��̷� 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) �̳���  ,  Sum(tot_adjst_amt) ������  
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
        and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		--and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����, �������� ���Խ� �ּ�ó��    
		and a.invce_yymm = '202006'    -- û����(�����) 
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		--and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		--                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
		  or  Sum(tot_adjst_amt) > 0
) y,
(
   select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, c.INVCE_ACCT_NO,
   count(*) paycnt, 
   sum(a.AF_INVCE_AMT) û���ݾ�, 
   sum(decode(a.cncl_yn,'Y',a.usg_amt)) �������ó���ݾ�
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between '202005'||'01' and '202005'||'99999999'  -- ���ſ�, ����� +1 ,û���� +1
		--and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm, c.INVCE_ACCT_NO
) z
where x.scrbr_no = y.scrbr_no(+)	
and x.scrbr_no = z.scrbr_no(+)	


-- PPV  �̳���� �� ���� ���͸� �� 
select x.roylt_type_cd ����,x.setl_dm �����, x.scrbr_no �����ȣ,z.INVCE_ACCT_NO û����ȣ, 
nvl(z.payamt*1.1,0) �̳������������͸��ݾ�,  y.tot_unpaid �ǹ̳��ݾ�, z.�������ó���ݾ� ����ұݾ�, y.adjst_amt �������ݾ�,
nvl(y.tot_unpaid,0) +  nvl(z.�������ó���ݾ�,0) + nvl(y.adjst_amt,0) �ǹ̳��Ѿ�
from (
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR
where setl_dm ='202006' -- û����(�����) 
and roylt_type_cd ='PPV'
) x,   
(
-- ppvod �̳��̷� 
		select a.scrbr_no ,  sum(a.NET_INVCE_AMT) tot_unpaid    , Sum(tot_adjst_amt) adjst_amt  
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
        and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����, �������� ���Խ� �ּ�ó��  
		and a.invce_yymm = '202006'    -- û����(�����) 
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		--and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		--                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
		   or  Sum(tot_adjst_amt) > 0
) y,
(
      select  a.scrbr_no,c.INVCE_ACCT_NO, c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt, sum(decode(CNCL_YN,'0',a.usg_amt)) �������ó���ݾ�
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  '202005'||'01' and '202005'||'99999999' -- ���ſ�, ����� +1 ,û���� +1
		--and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		--and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no	,c.INVCE_ACCT_NO, c.svc_open_dh, c.scrbr_nm
) z
where x.scrbr_no = y.scrbr_no(+)		
and x.scrbr_no = z.scrbr_no(+)			
order by nvl(y.tot_unpaid,0) desc,  nvl(z.payamt,0) desc 

	
-- VOD�̳����� ���͸� 	
select * 
from (
	select 
	'VOD���꿹��' "����",
	:mm ���ſ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt ������ż� , x.payamt ������űݾ� ,  x.payamt*1.1 ���������رݾ�,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)  �ʰ�����������, 
	y.avg_paycnt ����ձ��ż� , 	y.avg_payamt ����ձ��űݾ� , tot_unpaid �����̳���  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'  -- ��������
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
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
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷�. �̳�+ �����ݾ� 
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		--and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
		      or  Sum(tot_adjst_amt) > 0 -- �����ݾ� �ִ°� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(�����̳���,0)  > 10000 and ������űݾ� > 10000 )-- �̳��� 1���� �̻�, û���� 1���� �̻� 
    or (���������� <= 1 and ������űݾ� > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and ������űݾ� > ����ձ��űݾ� * 5 and ������űݾ� > 100000) -- ����̿뺸�� 5�� �̿�, 10���� �̻� 
	);

   
   
-- PPV�̳����� ���͸� 	
select * 
from (
	select  
	'PPV���꿹��' "����",
	OTS����,
	:mm ���ſ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt ������ŰǼ� , x.payamt ������űݾ� ,  x.payamt*1.1 ���������رݾ�,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)  �ʰ�����������, 
	y.avg_paycnt ����ձ��ż� , 	y.avg_payamt ����ձ��ž� , tot_unpaid �����̳���  
	from (	
		select  
            decode(d.scrbr_no ,null,'����','OTS') OTS����,
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
            group by decode(d.scrbr_no ,null,'����','OTS') , 
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
		-- ppvod �̳��̷�. ����3����  
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
		  or  Sum(tot_adjst_amt) > 0 -- �����ݾ� �ִ°� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
--and OTS���� = 'OTS'
    and
	(  (nvl(�����̳���,0)  > 0 and �����̳��� > 10000 and ������űݾ� > 10000)-- �̳��� 1���� �̻�, ���űݾ� 1���� �̻�
    or (���������� <= 1 and ������űݾ� > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and ������űݾ� > ����ձ��ž� * 20 and ������űݾ� > 50000) -- ����̿뺸�� 20�� �̿�, 5���� �̻� 
	)
  
     


-- VOD �̳� ���� ���� 
select xx.*,' ', yy.* from (
-- ppvvod �̳��̷� 
select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
from invce_cnfm_info a, invce_item_info b  
where 1= 1 
and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm')   -- Ư�� û���� �Ⱓ ����  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by a.invce_yymm, a.scrbr_no
having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
) xx, (
-- VOD�̳����� ���͸� 	
select * 
from (
	select 
	'VOD���꿹��',
	:mm ���ؿ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt , x.payamt , x.payamt*1.1 ����ݾ�,
	y.avg_paycnt , 	y.avg_payamt ,
	round(x.payamt/nullif(y.avg_payamt,0),1)*100  �ʰ���,
	tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
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
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷� 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		and a.pay_full_stat_cd = 'O'     -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'   -- ��� û���ݾ� ����  
		and a.invce_yymm between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 10000 and payamt > 0)-- �̳��� 1���� �̻�
    or (���������� <= 1 and payamt > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and payamt > avg_payamt * 5 and payamt > 100000) -- ����̿뺸�� 5�� �̿�, 10���� �̻� 
	)
) yy
where xx.scrbr_no(+) = yy.scrbr_no 
   
   

-- PPV �̳� ���� ���� 
select xx.*,' ', yy.* from (
	-- ppvvod �̳��̷� 
	select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
	from invce_cnfm_info a, invce_item_info b  
	where 1= 1 
	and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
	and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
	--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
	and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm') -- û���������̹Ƿ� +1 ���� 
	and b.invce_grp_cd IN ('120','125') 
	and a.open_item_cd  = b.open_item_cd  
	group by a.invce_yymm, a.scrbr_no
	having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
) xx, 
(
-- PPV�̳����� ���͸� 	
select * 
from (
	select  
	'PPV���꿹��' "����",
	:mm ���ſ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt ���ŰǼ� , x.payamt ���űݾ� ,  x.payamt*1.1 ������رݾ�,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100   �ʰ������, 
	y.avg_paycnt ����ձ��ż� , 	y.avg_payamt ����ձ��ž� , tot_unpaid �̳���  
	from (	
		select  
            decode(d.scrbr_no ,null,'����','OTS') ����,
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
            group by decode(d.scrbr_no ,null,'����','OTS') , 
            a.scrbr_no	, decode(d.scrbr_no ,null,c.svc_open_dh,d.svc_open_dt), c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/3,1) avg_paycnt, round(sum(a.usg_amt)/3 , 0) avg_payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷�. ����3����  
		select a.scrbr_no , sum(a.NET_INVCE_AMT)+Sum(tot_adjst_amt) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		--and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
		  or  Sum(tot_adjst_amt) > 0 -- �����ݾ� �ִ°� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(�̳���,0)  > 0 and �̳��� > 10000 and ���űݾ� > 10000)-- �̳��� 1���� �̻�, ���űݾ� 1���� �̻�
    or (���������� <= 1 and ���űݾ� > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and ���űݾ� > ����ձ��ž� * 20 and ���űݾ� > 50000) -- ����̿뺸�� 20�� �̿�, 5���� �̻� 
	)  
) yy
where xx.scrbr_no(+) = yy.scrbr_no



-- PPV �̳��� ����
select xx.*, yy.* from (
	-- ppvvod �̳��̷� 
	select a.invce_yymm, a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
	from invce_cnfm_info a, invce_item_info b  
	where 1= 1 
	and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
	and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
	--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
	and a.invce_yymm =  to_char(add_months(to_date(:mm,'yyyymm'),1),'yyyymm')
	and b.invce_grp_cd IN ('120','125') 
	and a.open_item_cd  = b.open_item_cd  
	group by a.invce_yymm, a.scrbr_no
	having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
) xx, (
-- PPV�̳����� ���͸� 	
select * 
from (
	select  
	'PPV���꿹��',
	:mm ���ؿ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt , x.payamt , 
	round(x.payamt/nullif(y.avg_payamt,0),1)*100  �ʰ���, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  :mm||'01' and :mm||'99999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no	, c.svc_open_dh, c.scrbr_nm
	) x, (
		select  a.scrbr_no, round(count(*)/6,1) avg_paycnt, round(sum(a.usg_amt)/6 , 0)avg_payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between to_char(add_months(to_date(:mm,'yyyymm'),-6),'yyyymm')||'01'  
		                  and  to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')||'999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷�. ����3����  
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-6),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 5000 and payamt > 0)-- �̳��� 0�� �̻�
    or (���������� <= 1 and payamt > 30000 )--  ó������ 10 �����̻� 
    or (���������� > 1 --and payamt > avg_payamt * 3 
	                     and payamt > 50000) -- ����̿뺸�� 5�� �̿�, 10���� �̻� 
	)
) yy
where xx.scrbr_no = yy.scrbr_no(+)


-- ppvod �̳��̷� 
select a.scrbr_no �����ȣ, sum(a.NET_INVCE_AMT) avg_unpaid  , 
Decode(b.invce_grp_cd,'120','PPV','125','VOD') û����ǰ�� 
from invce_cnfm_info a, invce_item_info b  
where 1=1  
and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
and a.invce_yymm between '201902' and '201904'    -- Ư�� û���� �Ⱓ ����  
and b.invce_grp_cd IN ('120','125') 
and a.open_item_cd  = b.open_item_cd  
group by a.scrbr_no, Decode(b.invce_grp_cd,'120','PPV','125','VOD')  , a.invce_yymm
having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 


  
-- PPV�̳�������� ��ȸ 
select * 
from (
	select  
	'PPV���꿹��' "����",
	:mm ���ؿ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt , x.payamt ,  x.payamt*1.1 ������رݾ�,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100   �ʰ������, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.usg_amt) payamt
		from cmcb06t01 a, cmcc01t01 c
		where a.recv_dh between  :mm||'01' and :mm||'99999999'
		and CNCL_YN='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
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
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷�. ����3����  
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid   
		from invce_cnfm_info a, invce_item_info b  
		where 1= 1 
		--and  Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'PPV'
		and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
)
where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 5000 and payamt > 0)-- �̳��� 0�� �̻�
    or (���������� <= 1 and payamt > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and payamt > avg_payamt * 30 and payamt > 50000) -- ����̿뺸�� 5�� �̿�, 10���� �̻� 
	)
	


-- VOD�̳�������� ��ȸ 
select * 
from (
	select 
	'VOD���꿹��' "����",
	:mm ���ؿ�,
	x.scrbr_no,scrbr_nm, 
	substr(svc_open_dh,1,6) ����� , 
	round((last_day(to_date(:mm,'yyyymm')) -  to_date(substr(svc_open_dh,1,8),'yyyymmdd'))/30,0) ����������,
	x.paycnt , x.payamt ,  x.payamt*1.1 ������رݾ�,
	round((x.payamt-nullif(y.avg_payamt,0))/nullif(y.avg_payamt,0),2)*100  �ʰ������, 
	y.avg_paycnt , 	y.avg_payamt , tot_unpaid  
	from (	
		select  a.scrbr_no,c.scrbr_nm, c.svc_open_dh, count(*) paycnt, sum(a.AF_INVCE_AMT) payamt
		from cmcb15t01 a, cmcc01t01 c
		where a.buy_dh between :mm||'01' and :mm||'99999999'
		and nvl(a.cncl_yn,'N') = 'N'
		and buy_type_cd ='1'
		and a.scrbr_no = c.scrbr_no
		and c.sale_type_cd = '1'
		and c.scrbr_nm not like '%�����%'
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
		and c.scrbr_nm not like '%�����%'
		group by a.scrbr_no
	) y, 
	(
		-- ppvod �̳��̷� 
		select a.scrbr_no , sum(a.NET_INVCE_AMT) tot_unpaid    
		from invce_cnfm_info a, invce_item_info b  
		where 1=1 
		--and Decode(b.invce_grp_cd,'120','PPV','125','VOD') = 'VOD'
		and a.pay_full_stat_cd = 'O'    -- �̳����� �ִ� �͸� ����  
		--and a.invce_yymm <> '201905'    -- ��� û���ݾ� ����  
		and a.invce_yymm between  to_char(add_months(to_date(:mm,'yyyymm'),-3),'yyyymm') 
		                     and to_char(add_months(to_date(:mm,'yyyymm'),-1),'yyyymm')    -- Ư�� û���� �Ⱓ ����  
		and b.invce_grp_cd IN ('120','125') 
		and a.open_item_cd  = b.open_item_cd  
		group by a.scrbr_no
		having sum(a.NET_INVCE_AMT) > 0 --�̳��ݾ��� �ִ� �͸� 
	) z
	where x.scrbr_no = y.scrbr_no(+)
	and x.scrbr_no = z.scrbr_no(+)
) where 1= 1 
    and
	(  (nvl(tot_unpaid,0)  > 0 and tot_unpaid > 10000 and payamt > 0)-- �̳��� 1���� �̻�
    or (���������� <= 1 and payamt > 100000 )--  ó������ 10 �����̻� 
    or (���������� > 1 and payamt > avg_payamt * 5 and payamt > 100000) -- ����̿뺸�� 5�� �̿�, 10���� �̻� 
	)
	

-- ���꿹�� ó�� ���̺� 
SELECT * FROM ROYLT_SETL_EXCLU_SCRBR  --- / �ǱǷ��������ܰ������� 	

