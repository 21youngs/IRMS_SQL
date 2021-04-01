                                                               


-- VOD ������ û���ݾ�, ��ݵ������ ��ȸ
select 
-- a.invce_yymm û����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--count(distinct a.scrbr_no)  ����ڼ�,
--sum(chrg_amnt) �ݾ�,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û�����αݾ�,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û���ݾ�  
from BILNG_TXN_INFO a, CHRG_INFO b  
where a.invce_yymm >= '202008' and a.invce_yymm <= '202010'  -- û�������� 
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '202008' and a.invce_yymm <= '202010'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
group by a.invce_yymm
order by a.invce_yymm

-- VOD  ������ ������ ����,  ����� ���� ��ȸ                                                    
select  substr(�����Ͻ�,1,6) ���ؿ�, sum(PREPAY_AMT) ī���޴�������, sum(PNT_AMT) ����Ʈ����, sum(usg_amt) �������Ѹ���                                                          
from (                                                                                         
select                                                                                         
b.scrbr_no ���԰���ȣ, b.scrbr_nm ���԰���,sc_id ,                                         
usg_amt,                                                                                       
PREPAY_AMT , 
PNT_AMT,                                                                                  
buy_dh �����Ͻ�, d.cd_nm ��������,                                                             
a.vod_id,c.title, main_cate_nm , sub_cate_nm , CONTENTS_CATE, CP_NM, DISTR_CMPY, PRDT_CMPY     
from cmcb15t01 a, cmcc01t01 b, mmab06t01 c, zzaa02t01 d                                        
where  buy_dh like '202009%' -- ��������                                                                    
--and af_invce_yn ='N'                                                                         
and a.scrbr_no = b.scrbr_no                                                                    
--and (a.prepay_amt <> 0 or pnt_amt <> 0 ) 
and PAY_TRNSN_ID is not null                                                                          
and a.vod_id = c.vod_id                                                                        
and a.PAY_MTH_CD = d.cd                                                                        
and d.cd_cl ='CM448'                                                                           
and nvl(a.cncl_yn,'N') = 'N'                                                                   
order by buy_dh                                                                                
) group by substr(�����Ͻ�,1,6)


-- VOD ������ ����, ��ݵ����ȸ
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--b.prdt_nm ��ǰ�ڵ��,
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008'  --û��������
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm 
--,b.prdt_nm


-- 2018092 ��ǰ ���嵿�� sky17 ��ǰ  û���ݾ� ��ȸ ��ݵ����ȸ
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,  
a.prdt_cd ��ǰ�ڵ�,
b.prdt_nm ��ǰ�ڵ��,
sum(a.invce_amt-a.disc_amt) ����,
count(a.scrbr_no) �����ڼ�
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm = '202008'  -- û�������� 
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd = '2018092'
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ,  
a.prdt_cd ,
b.prdt_nm	

-- vod5k, 18k  ��ǰ  û���ݾ� ��ȸ, ��ݵ����ȸ
SELECT /*+ USE_HASH(b a) */  
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�, 
a.prdt_cd ��ǰ�ڵ�,
b.prdt_nm ��ǰ�ڵ��,
sum(a.invce_amt-a.disc_amt) ����,
count(a.scrbr_no) �����ڼ�
FROM chrg_info a, prdt_info b
WHERE 1=1
AND a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
AND a.invce_yymm = '202008'  -- û��������
AND a.prdt_cd = b.prdt_cd
AND a.prdt_cd in ( '2019009', '2020007')  -- 2019009 5K, 2019010 18K, 2020007 18K(û������ �����ڵ�)
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') , 
a.prdt_cd ,
b.prdt_nm


-- ���� ������ ����, ��ݵ����ȸ
select /*+ USE_HASH(b a) */   
invce_yymm û����,  
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
substr(b.prdt_nm,1,3),
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm = '202008'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('34')
group by invce_yymm  ,substr(b.prdt_nm,1,3)


-- ���� PPV û����� , ��ݵ����ȸ
select
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  ����PPVû���ݾ�
from BILNG_TXN_INFO a, CHRG_INFO b
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008' --û����
and a.unit_svc_cd = 'PPV' 
and b.invce_yymm >= '202008' and a.invce_yymm <= '202008'  -- û����
and b.unit_svc_cd = 'PPV' 
and a.scrbr_no = b.scrbr_no
and a.invce_yymm = b.invce_yymm
group by a.invce_yymm
order by  a.invce_yymm



-- OTS PPV û����� , ��ݵ����ȸ
select 
--invce_yymm û����, 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--to_char(ADD_MONTHS ( to_date(max(invce_yymm),'YYYYMM') , -1 ),'YYYYMM') , 
sum(chrg_amnt)	OTSû������	
from bilng_txn_info	a	
where invce_yymm  >= '202008' and a.invce_yymm <= '202008'  --û����
and unit_svc_cd = 'KTPPV'	
group by invce_yymm	
order by 1

007005

--  PPV ������ û������ , ��ݵ����ȸ   2020.5��  PPV������ �з����� ������                                                     
select /*+ USE_HASH(b a) */                                                    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�, 
--b.prdt_nm,
      sum(invce_amt-disc_amt) PPV������û������                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '202008' and a.invce_yymm <= '202008'    --û����                                            
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%PPV%'                                                          
group by invce_yymm     
--, b.prdt_nm                                                       



-- ppv ������ 
select substr(�����Ͻ�,1,6) �� ,
-- ��������,  
sum(usg_amt ) PPV����������
--, sum(usg_amt )*1.1
from (
SELECT
'PPV' ��ǰ����,
 a.recv_dh �����Ͻ� , a.sc_id ����Ʈī���ȣ,  b.PPV_SVC_ID vod_id, b.pgm_nm title, 
 --c.chl_no ä�ι�ȣ, c.chl_nm ä�θ�,
 PAY_TRNSN_ID PAY_TRNSN_ID,
 g.scrbr_nm ���԰���,
 decode(f.scrbr_no ,null,'����','OTS') ���Ա���, 
case when g.sale_type_cd = '2' or g.scrbr_nm like '%�����%' then '�����' 
end ����뱸��,
 e.cd_nm ��������,
a.usg_amt ,
--trunc(PRDT_PRCE*1.1,-1) "����(�ΰ�������)", 
--trunc(PREPAY_AMT*1.1,-1) "�������ݾ�(�ΰ�������)",
trunc(PREPAY_AMT*1.1,-1) "����ݾ�(�ΰ�������)"
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
group by  substr(�����Ͻ�,1,6)
--, ��������



-- 7. IP���ᰡ�� ���ű� ���������ڼ� ��ȸ(����)
select 
substr(a.dt,1,6) ��,
dt ������, /*
		case 
	   when equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�, */
 sum(a.MAIN_CNT) ������
from mmec50t01 a, mmda03t01 b , zzaa02t01 c
where dt in ( '20200731')
and a.equip_model_no = b.equip_model_no
and b.stb_grp_cd = c.cd
and c.cd_cl ='MM083'
and IP_YN ='0'
and c.cd_nm not like '%OTS%'
group by  dt


-- ip�������� 
select substr(nalja,1,6) mm , count(*)
from aptest.ip_callback_new_report a 
where nalja in ('20200731') 
and a.gubun = '��������'
group by substr(nalja,1,6)



-- 6. �Ⱓ�� vod ����ڼ� ��ȸ
select
--x.���ű�з�, x.������,x.������code,
-- ����,
--sum(decode(buy_type_cd,'1',count(distinct scrbr_no)) )�������ڼ�,
max(������) dt,
count(distinct �����) ����������ڼ�,
count(distinct ��������) ��������������,
count(distinct �����) - count(distinct ��������) ��������������,
sum(decode(buy_type_cd,'1',usg_amt,0)) VOD����
from (
	select substr(buy_dh ,1, 8) ������, title,
		case 
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�,
	usg_amt ,
	buy_type_cd, 
	h.crcl_net_nm ������ ,h.crcl_net_cd ������code,  g.crcl_net_nm ����, i.crcl_net_nm ����,
	decode(buy_type_cd,'1', a.sc_id,'') ��������,
	decode(buy_type_cd,'2', a.sc_id,'') �����׻����,
	a.sc_id �����
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, mmca01t01 g, mmca01t01 h, mmca01t01 i
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between  '20200701' and '20200731'||'999999'				
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	--and a.scrbr_no='0000737728'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%�����%'	
	--and buy_type_cd ='1'  -- ������ ���ŰǸ� 
	and c.instal_crcl_net_cd = g.crcl_net_cd
	and g.MGMT_BIZ_OFCE_CD = h.crcl_net_cd
	and g.A_RSLT_MGMT_BIZ_OFCE_CD = i.crcl_net_cd
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%'
					)
)x 



-- �����װ����ڼ� , sky17,vod������,���� �ߺ����� �����ڼ� 
select  mm ��	, count(distinct scrbr_no) �����׻�ǰ������
from (
        (
		-- �����װ���
		select  --+ parallel (a)
		        mm,  a.scrbr_no 
				from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
				    ( /* ���� ���ϱ� */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
				where a.svc_open_dh <  d.mm||'31999999'
				and nvl(a.rscs_dh,'29991231') > d.mm||'01' -- �����������
				and a.scrbr_no=b.scrbr_no
				and a.prdt_cd=c.prdt_cd 
				and B.SALE_TYPE_CD='1'
				and b.scrbr_nm not like '%�����%'
				and c.prdt_type_cd in ('25','26','34')				
				group by 	mm,  a.scrbr_no		
		)
		union all															
        (
		-- ���ο���������,skyA17
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
		 ( /* ���� ���ϱ� */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
		where  a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- �����������
		AND a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and (c.prdt_type_cd in ('34') or c.prdt_cd ='2018010')  -- skyA 17   
		--and a.prdt_cd in ('2018018', '2019001')
		and b.SALE_TYPE_CD='1'
		and b.scrbr_nm not like '%�����%'
		group by 	mm,  a.scrbr_no						
		)					
)group by 	mm


-- ���� �����ڼ�(�����������)
select  '����' ����, mm, prdt_nm	, 
count(*)
from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
 ( /* ���� ���ϱ� */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202101'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
where  a.svc_open_dh <  d.mm||'31999999'
and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- �����������
-- and nvl(a.rscs_dh,'29991231') > d.mm||'31'   -- �����������
AND a.scrbr_no=b.scrbr_no
and a.prdt_cd=c.prdt_cd 
and c.prdt_type_cd in ('34')	
--and a.prdt_cd in ('2018018', '2019001')
and b.SALE_TYPE_CD='1'
and b.scrbr_nm not like '%�����%'
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh  between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%'
					)
group by mm , prdt_nm			

select count(*) 
from cmcc02t01 a where   a.svc_open_dh <  '202001'||'31999999'
and nvl(a.rscs_dh,'29991231') > '202001'||'31'   -- �����������
and a.prdt_cd in  ('2018018')

-- skyA17 �����ڼ�(�����������)
select mm, prdt_nm	, count(*)
from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
( /* ���� ���ϱ� */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202007'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
where a.svc_open_dh <  d.mm||'31999999'
and nvl(a.rscs_dh,'29991231') > d.mm  -- ����������� 
and a.scrbr_no=b.scrbr_no
and a.prdt_cd=c.prdt_cd 
and B.SALE_TYPE_CD='1'
and b.scrbr_nm not like '%�����%'	
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and nvl(substr(a.rscs_dh,1.8),'29991231') between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%' )
and c.prdt_cd ='2018010' -- skyA 17			
group by mm, prdt_nm				



-- �����װ����ڼ�(�����������)
select 
mm, 
--prdt_nm	, 
count(*)
from (
select 
case when c.prdt_type_cd = '34' then 'OTT'
	 when c.prdt_nm like '%MBC%' or c.prdt_nm like '%SBS%' or c.prdt_nm like '%KBS%' or c.prdt_nm like '%������%' then '������'
	 when c.prdt_nm like '%CJ%'  then '�ٽú���'
	 when c.prdt_nm like '%JTBC%'  then '�ٽú���'
	 when c.prdt_nm like '%ä��%'  then '�ٽú���'
	 when c.prdt_nm like '%MBN%'  then '�ٽú���'
	 when c.prdt_nm like '%�ִ�%'  then 'Ű��/��Ÿ'
	 when c.prdt_nm like '%���Ϲ���%'  then 'Ű��/��Ÿ'
	 when c.prdt_nm like '%PLAYY%'  then 'Ű��/��Ÿ'
	 when c.prdt_nm like '%������%'  then 'Ű��/��Ÿ'
	 when c.prdt_nm like '%EBS%'  then 'Ű��/��Ÿ'
	 else '�µ���'
end ����,
		a.scrbr_no , c.prdt_nm, mm
		from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
		    ( /* ���� ���ϱ� */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '202007'  
				group by dt, substr(dt,1,6)) 
			group by mm) d
		where a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- �����������
		and a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and B.SALE_TYPE_CD='1'
		--and c.prdt_nm like '%������%'	
		and c.prdt_type_cd in ('25','26')				
        and not exists (select 1 from cmcd01t01 x, mmaj01t01 y where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.svc_open_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and nvl(substr(a.rscs_dh,1.8),'29991231') between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%' )
)group by  mm	--, prdt_nm


-- VOD�ߺ����� �̿��ڼ� , ������, ������, sky17,vod������,���� �ߺ����� �����ڼ� 
select  mm ��	, count(distinct scrbr_no) VOD�̿���
from (
        (
		-- �����װ���
		select  --+ parallel (a)
		        mm,  a.scrbr_no 
				from cmcc03t01 a, cmcc01t01 b, mmaa04t01 c, 
				    ( /* ���� ���ϱ� */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
				where a.svc_open_dh <  d.mm||'31999999'
				and nvl(a.rscs_dh,'29991231') > d.mm||'01' -- �����������
				and a.scrbr_no=b.scrbr_no
				and a.prdt_cd=c.prdt_cd 
				and B.SALE_TYPE_CD='1'
				and b.scrbr_nm not like '%�����%'
				and c.prdt_type_cd in ('25','26','34')				
				group by 	mm,  a.scrbr_no		
		)
		union all															
        (
		-- ���ο���������,skyA17
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcc02t01 a, cmcc01t01 b, mmaa04t01 c,
		 ( /* ���� ���ϱ� */
					select max(dt) dd , mm                                  
					from (                               
						select dt, substr(dt,1,6) mm 
						from mmec18t01               
						--where dt > '202002' and   dt < '202003'
						where dt like '202007%'
						group by dt, substr(dt,1,6)) 
					group by mm) d
		where  a.svc_open_dh <  d.mm||'31999999'
		and nvl(a.rscs_dh,'29991231') > d.mm||'01'   -- �����������
		AND a.scrbr_no=b.scrbr_no
		and a.prdt_cd=c.prdt_cd 
		and (c.prdt_type_cd in ('34') or c.prdt_cd ='2018010')  -- skyA 17   
		--and a.prdt_cd in ('2018018', '2019001')
		and b.SALE_TYPE_CD='1'
		and b.scrbr_nm not like '%�����%'
		group by 	mm,  a.scrbr_no						
		)
		union all															
        (
		-- ������ �̿���
		select  --+ parallel (a)
		mm,  a.scrbr_no 
		from cmcb15t01 a, cmcc01t01 b,
		 ( /* ���� ���ϱ� */
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
		and b.scrbr_nm not like '%�����%'
		group by 	mm,  a.scrbr_no						
		)					
)group by 	mm






--  ppv �ֹ����� ���������ڼ� 
select /*+ parallel (a) */
:mm ��,
'����' ,
   decode(f.sc_id,null,'����','����') ppv_vod��������, 	   
   count(distinct a.sc_id) ������                 
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
and e.entr_cl_cd not in ('Y','Z','A','B','C')  -- ����, �̵�ü ����
and e.recv_mth_cd like '1%'      -- �Ϲݹ�ĸ� 
and a.MST_FILE_STAT_CD not in ('2','3')  -- �������� 
and not exists (select 1 from cmcc06t01 g where a.scrbr_no = g.scrbr_no 
                and :mm||'31' between g.SUSPN_FR_DH and nvl(g.SUSPN_CNCL_DH,'29991231')
				)
group by decode(f.sc_id,null,'����','����') 



--  ppv �ֹ����� OTS �����ڼ� 
select /*+ parallel (a) */
:mm ��,
'OTS' ����,
   decode(f.sc_id,null,'����','����') ppv_vod��������, 	   
   count(distinct a.scrbr_no) ������                 
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
and a.MST_FILE_STAT_CD not in ('2','3')  -- �������� 
and :mm||'31' between a.SVC_OPEN_Dt and nvl(a.rscs_dt,'29991231') 
and :mm||'31' between b.SVC_OPEN_Dt and nvl(b.rscs_dt,'29991231') 
group by decode(f.sc_id,null,'����','����') 


-- ppv ��ǰ�� ����ڼ� , ����
select ��,����, 
��ǰ����,
count(distinct scrbr_no) ����ڼ�,
sum(��ǰ�ݾ�)
from(
SELECT substr(a.recv_dh,1,6) ��, 
	decode(f.scrbr_no ,null,'����','OTS') ����,
	substr(chl_nm,1,2) ��ǰ����,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') ����, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') ����,
	b.pgm_nm ��ǰ��, b.pgm_grade ��ǰ���, c.chl_no ä�ι�ȣ, c.chl_nm ä�θ�,
	a.usg_amt ��ǰ�ݾ�, a.recv_dh �ֹ���, e.cd_nm �ֹ����, a.scrbr_no
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV����%' or y.prdt_nm like '%����Ƽī����%') 
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
	  and f.scrbr_no||g.scrbr_no is not null  -- ������� �߶󳻱� �������� 
)	group by �� , ����,
��ǰ����


-- ppv ����ڼ�(�ߺ�����) , ����
select ��,  
--��,����, ��ǰ����,
count(distinct scrbr_no) ����ڼ�,
count(*) �ֹ���,
sum(��ǰ�ݾ�) ����������
from(
SELECT substr(a.recv_dh,1,6) ��, substr(a.recv_dh,1,8) ��,
	decode(f.scrbr_no ,null,'����','OTS') ����,
	substr(chl_nm,1,2) ��ǰ����,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') ����, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') ����,
	b.pgm_nm ��ǰ��, b.pgm_grade ��ǰ���, c.chl_no ä�ι�ȣ, c.chl_nm ä�θ�,
	a.usg_amt ��ǰ�ݾ�, a.recv_dh �ֹ���, e.cd_nm �ֹ����, a.scrbr_no
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV����%' or y.prdt_nm like '%����Ƽī����%') 
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
	  and f.scrbr_no||g.scrbr_no is not null  -- ������� �߶󳻱� �������� 
)	group by �� --,����,��ǰ����



-- ���� ���αݾ� ��ȸ  
select ���ſ�, 
sum(case when COUPON_ISSUE_CD in (71,67,127,134,160) then DISC_AMT end) ��������������,
sum(case when COUPON_ISSUE_CD in (527,528) then DISC_AMT end) ������������,
sum(case when COUPON_ISSUE_CD = 80 then DISC_AMT end ) sky17�ص���������,
sum(case when COUPON_ISSUE_CD is null and USG_AMT > 0 and ������ in (20,30, 50) then DISC_AMT end ) skyA�����������θ��,
sum(case when COUPON_ISSUE_CD not in (80,71,67,127,134,160,208,209,210,527,528) then DISC_AMT end ) ���θ������,
sum(case when COUPON_ISSUE_CD in (208,209,210,515,516) then DISC_AMT end ) ������VOC����,
sum(case when COUPON_ISSUE_CD is null and ������ not in (20, 50,30) then DISC_AMT end ) ��Ÿ����,
--sum(USG_AMT) VOD�������������� , 
sum(DISC_AMT) �����αݾ�
from ( 
-- ���� ���λ�볻�� 
select 
substr(a.buy_dh, 1,6) ���ſ�, 
substr(a.buy_dh, 1,8) ������, 
case 
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�,COUPON_ISSUE_CD,
 a.scrbr_no ,a.sc_id, b.vod_id, b.title,  a.USG_AMT, a.DISC_AMT, PRDT_PRCE, round(a.DISC_AMT/PRDT_PRCE,1)* 100 ������, 
 decode(a.DISC_AMT,0,'������','', '������', decode(COUPON_ISSUE_CD,'','skyA����','��������')) �������ο���
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between '20200701' and '20200731'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	--and a.scrbr_no='0000737728'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%�����%'	
	and buy_type_cd ='1'  -- ������ ���ŰǸ� 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%'
					)
	--and COUPON_ISSUE_CD is not null
	--and nvl(COUPON_ISSUE_CD,'-') not like 'E%'
    and DISC_AMT > 0
)
group by ���ſ�
--, ���ű�з�	


-- ������� KPI ��ȸ�� ���
========================================================================================
























-- 2018092 ��ǰ ���嵿�� sky17 ��ǰ  û���ݾ� ��ȸ
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,  
a.prdt_cd ��ǰ�ڵ�,
b.prdt_nm ��ǰ�ڵ��,
sum(a.invce_amt-a.disc_amt) ����,
count(a.scrbr_no) �����ڼ�
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



-- ������ ���� PPV ��볻�� 
SELECT-- invce_yymm û�����, 
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
Sum(disc_amt) ���αݾ�,
count(distinct a.scrbr_no) ����ڼ�,
count(*) ����
FROM bilng_txn_info a
WHERE unit_svc_cd = 'PPV'
AND disc_adpt_info = '21746'
and a.invce_yymm >= '202003' 
GROUP BY to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm')
ORDER BY 1
;


==================================================================================================
































-- VOD ������ ���� 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
sum(invce_amt-disc_amt)  VOD������û������ ,
count(distinct a.scrbr_no)
from CHRG_info a , zzaa02t01 b
where a.invce_yymm >= '201903' and a.invce_yymm <= '201904'
and a.invce_prdt_cd = b.cd
and b.cd_cl = 'BM021'
and cd_nm like '%������%'
and (cd_nm like '%VOD%'
	    or  cd_nm like '%������%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --�����߰� �ʿ�
		or  cd_nm like '%�ִϸƽ�%' --�����߰� �ʿ�
		or  cd_nm like '%MBN%' --�����߰� �ʿ�
		or  cd_nm like '%ä��%' --�����߰� �ʿ�
		or  cd_nm like '%������%' --�����߰� �ʿ�
		or  cd_nm like '%�ִ��÷���%' --�����߰� �ʿ�
		or  cd_nm like '%EBS%' --�����߰� �ʿ�
	   ) 
group by invce_yymm  





--  PPV ������ û������    2019.3�� ������                                                     
select /*+ parallel (a) */                                             
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�, 
b.prdt_nm,
sum(invce_amt-disc_amt) PPV������û������,
count(distinct scrbr_no) �����ڼ�                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '201302'                                                 
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%����%'                                                          
group by invce_yymm   ,b.prdt_nm                                                         
order by invce_yymm

--  PPV ������ û������    2019.3�� ������                                                     
select /*+ USE_HASH(b a) */                                                    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�, 
b.prdt_nm,
sum(invce_amt-disc_amt) PPV������û������,
count(distinct scrbr_no) �����ڼ�                                
from  chrg_info a, MMAA04T01 b, prdt_fix_chrg c                                                
where a.invce_yymm >= '201302'                                                 
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd                                                     
AND a.invce_seq_no = 1                                                       
AND a.invce_type_cd = 'R' 
and b.prdt_type_cd in ('92')
and b.prdt_nm like '%����%'                                                          
group by invce_yymm   ,b.prdt_nm                                                         
order by invce_yymm

-- VOD ������ ���� 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a
where invce_yymm = '201903'  
and a.invce_prdt_cd in (
	select cd from zzaa02t01 b  where cd_cl = 'BM021'
	and cd_nm like '%������%'
	and ( cd_nm like '%VOD%'
	    or  cd_nm like '%������%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --�����߰� �ʿ�
		or  cd_nm like '%�ִϸƽ�%' --�����߰� �ʿ�
		or  cd_nm like '%MBN%' --�����߰� �ʿ�
		or  cd_nm like '%ä��%' --�����߰� �ʿ�
		or  cd_nm like '%������%' --�����߰� �ʿ�
		or  cd_nm like '%�ִ��÷���%' --�����߰� �ʿ�
		or  cd_nm like '%EBS%' --�����߰� �ʿ�
	    ) 
)group by invce_yymm                                                                                      



select to_char(BRDCST_FR_DH,'yyyymmddhhhh24miss') from  BILNG_TXN_INFO


select * from  mmag02t01@LN_SCISCM_WEBLOGIC



-- ���� PPV û����� 
select
'����' ���Ա���,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
	case 
    when  to_number(c.chl_no) >= 221  then '����' 
	else '����'
	end ä�α���,
c.chl_no,
a.PGM_NM,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  û���ݾ�
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
-- OTS PPV û����� 
select 
'OTS',
--invce_yymm û����, 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--to_char(ADD_MONTHS ( to_date(max(invce_yymm),'YYYYMM') , -1 ),'YYYYMM') , 
	case 
    when  to_number(c.chl_no) >= 221  then '����' 
	else '����'
	end ä�α���,
c.chl_no,
a.PGM_NM,
sum(chrg_amnt)	OTSû������	
from bilng_txn_info	a	, mmab03t01@LN_SCISCM_MM c
where invce_yymm  >= '201701' and a.invce_yymm <= '201904'
and unit_svc_cd = 'KTPPV'	
and a.ppv_svc_id = c.ppv_svc_id
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss')= c.svc_open_dh
group by invce_yymm	, c.chl_no, a.PGM_NM





-- ���� PPV û����� , ���񷹵� ,ä�κ� �з� 
select  /*+ parallel (a) */
'����' ����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
substr(d.chl_nm,1,2) ��ǰ����,
c.chl_no,	
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  PPVû���ݾ�
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
-- OTS PPV û����� , ���񷹵� ,ä�κ� �з� 
select /*+ parallel (a) */
'OTS' ����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
substr(d.chl_nm,1,2) ��ǰ����,
c.chl_no,	
sum(chrg_amnt)	OTSû������	
from bilng_txn_info a	, mmab03t01@LN_SCISCM_WEBLOGIC c, mmag02t01@LN_SCISCM_WEBLOGIC d
where invce_yymm  >= '201701'
and unit_svc_cd = 'KTPPV'	
and a.PPV_SVC_ID = c.ppv_svc_id
AND to_char(a.brdcst_fr_dh,'yyyymmddhh24miss') = c.svc_open_dh
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
group by a.invce_yymm, substr(d.chl_nm,1,2), c.chl_no







--  PPV ������ û������                                                        
select /*+ USE_HASH(b a) */                                                    
      --invce_yymm û���� ,                                                    
      to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,    
      --sum(scrbr_cnt) ����ڼ�,                                               
      sum(invce_amt-disc_amt) PPV������û������                                
from  chrg_info a, zzaa02t01 b                                                 
where a.invce_yymm  >= '201702' and invce_yymm <= '201801'                                                
and   a.invce_prdt_cd = cd                                                     
and   cd_cl = 'BM021'                                                          
AND   a.invce_seq_no = 1                                                       
AND   a.invce_type_cd = 'R'                                                    
and   (cd_nm like '%PPV%' or cd_nm like '%����Ƽī%')                          
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
      )  -- ������                                                             
group by invce_yymm                                                            
order by invce_yymm                                                            


--  PPV ������ û������                                                        
select /*+ USE_HASH(b a) */                                                    
      --invce_yymm û���� ,   
	  b.cd_nm,                                                  
      to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,    
      --sum(scrbr_cnt) ����ڼ�,                                               
      sum(invce_amt-disc_amt) PPV������û������   ,
	  count(a.scrbr_no)                             
from  chrg_info a, zzaa02t01 b                                                 
where a.invce_yymm = '201810'                                                  
and   a.invce_prdt_cd = cd                                                     
and   cd_cl = 'BM021'                                                          
AND   a.invce_seq_no = 1                                                       
AND   a.invce_type_cd = 'R'                                                    
and   (cd_nm like '%PPV%' or cd_nm like '%����Ƽī%')                          
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
      )  -- ������                                                             
group by invce_yymm   , b.cd_nm                                                         
order by invce_yymm                                                            



--  PPV ������ û������  
select 
--invce_yymm û���� , 
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--sum(scrbr_cnt) ����ڼ�,
sum(invce_amt-disc_amt) PPV������û������
from chrg_info a, zzaa02t01 b
where invce_yymm = '201811'  and a.invce_prdt_cd = cd
and cd_cl = 'BM021'
AND a.invce_seq_no = 1
AND a.invce_type_cd = 'R'
and (cd_nm like '%PPV%' or cd_nm like '%����Ƽī%')
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
)  -- ������
group by invce_yymm
order by invce_yymm 






-- ppv ������ 
select ���Ա���, substr(�����Ͻ�,1,6) �� , sum(usg_amt )
from (
SELECT
'PPV' ��ǰ����,
 a.recv_dh �����Ͻ� , a.sc_id ����Ʈī���ȣ,  b.PPV_SVC_ID vod_id, b.pgm_nm title, 
 --c.chl_no ä�ι�ȣ, c.chl_nm ä�θ�,
 PAY_TRNSN_ID PAY_TRNSN_ID,
 g.scrbr_nm ���԰���,
 decode(f.scrbr_no ,null,'����','OTS') ���Ա���, 
case when g.sale_type_cd = '2' or g.scrbr_nm like '%�����%' then '�����' 
end ����뱸��,
 e.cd_nm �ֹ�����,
a.usg_amt ,
--trunc(PRDT_PRCE*1.1,-1) "����(�ΰ�������)", 
--trunc(PREPAY_AMT*1.1,-1) "�������ݾ�(�ΰ�������)",
trunc(PREPAY_AMT*1.1,-1) "����ݾ�(�ΰ�������)"
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
group by  substr(�����Ͻ�,1,6), ���Ա���





-- ���ű� ������ 
select substr(dt,1,6) ��, 
 sum(a.MAIN_CNT) ������
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


-- ppv ����ڼ� , ����
select ��,
����, 
��ǰ����,
count(distinct sc_id) ����ڼ�,
sum(��ǰ�ݾ�)
from(
SELECT substr(a.recv_dh,1,6) ��, 
	decode(f.scrbr_no ,null,'����','OTS') ����,
	substr(chl_nm,1,2) ��ǰ����,
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'dy') ����, 
	to_char(to_date(substr(a.recv_dh ,1, 8),'yyyymmdd'),'iw') ����,
	b.pgm_nm ��ǰ��, b.pgm_grade ��ǰ���, c.chl_no ä�ι�ȣ, c.chl_nm ä�θ�,
	a.usg_amt ��ǰ�ݾ�, a.recv_dh �ֹ���, e.cd_nm �ֹ����, a.scrbr_no, a.sc_id
	    FROM cmcb06t01 a, mmab03t01 b, mmag02t01 c, zzaa02t01 e, ots_scrbr f, cmcc01t01 g,
		    (select distinct x.scrbr_no from cmcc02t01 x,  mmaa04t01 y
			where x.prdt_cd=y.prdt_cd 
			  and  (y.prdt_nm like '%PPV����%' or y.prdt_nm like '%����Ƽī����%') 
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
	  and f.scrbr_no||g.scrbr_no is not null  -- ������� �߶󳻱� �������� 
)	group by ��  , ����, ��ǰ����


-- ppv ����ڼ� , 
SELECT substr(a.recv_dh,1,6) ��, count(distinct a.scrbr_no)
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
	  

-- VOD ������ ����, �ñ����� 
select /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
d.do_nm, sigun_nm,
cd_nm,
sum(invce_amt-disc_amt)  VOD������û������ ,
count(distinct a.scrbr_no) �����ڼ�
from CHRG_info a , zzaa02t01 b, cmcc01t01 c, 
(select zip_cd, min(do_nm) do_nm,min(sigun_nm) sigun_nm, min(TOWN_NM) TOWN_NM, min(DELVR_PLCE_RI_NM)DELVR_PLCE_RI_NM
		       from zzaa03t01@LN_SCISCM_MM 
			   where do_nm in ('����','���') 
			   and sigun_nm in ('������','��걸','���빮��','����','�߱�', '��������','���α�','������', '���� ���籸')
		       group by zip_cd) d 
where invce_yymm = '201812'  
and a.invce_prdt_cd = b.cd
and b.cd_cl = 'BM021'
and cd_nm like '%������%'
and (cd_nm like '%VOD%'
	    or  cd_nm like '%������%'
		or  cd_nm like '%KBS%'
		or  cd_nm like '%MBC%'
		or  cd_nm like '%SBS%'
		or  cd_nm like '%PLAYY%' --�����߰� �ʿ�
		or  cd_nm like '%�ִϸƽ�%' --�����߰� �ʿ�
		or  cd_nm like '%MBN%' --�����߰� �ʿ�
		or  cd_nm like '%ä��%' --�����߰� �ʿ�
		or  cd_nm like '%������%' --�����߰� �ʿ�
		or  cd_nm like '%�ִ��÷���%' --�����߰� �ʿ�
		or  cd_nm like '%EBS%' --�����߰� �ʿ�
	   ) 
and a.scrbr_no = c.scrbr_no
and c.INSTAL_PLCE_ZIP_CD = d.zip_cd	   
group by invce_yymm, d.do_nm, sigun_nm	, cd_nm  
having sum(invce_amt-disc_amt) > 0


select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201905'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')


-- ���ű⺰ ������ û������ ��ȸ 
-- ��ݵ�� ��ȸ, VOD ������ û������ ��ȸ  ��ǰ��, �����ںм�, �Ϻ� ���� ���� �Ѿ׺��� �۰� ���� 
SELECT/*+ use_hash (c a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--equip_model_no, equip_model_nm,
	case
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�,
Sum(invce_amt)-Sum(disc_amt) ���ű⺰�����׸��� ,
count(c.scrbr_no)
FROM chrg_info a,  cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, MMAA04T01 g, prdt_fix_chrg h
WHERE invce_yymm = '201905' -- û���� 
And invce_type_cd = 'R'  --�߰�
And invce_seq_no = 1 --�߰�
and a.chrg_item_cd = h.chrg_item_cd
and h.prdt_cd = g.prdt_cd
and g.prdt_type_cd in ('25','26')
and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and a.scrbr_no = e.scrbr_no
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < invce_yymm  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > invce_yymm  -- ���űⱳü�� �ֹ��Ͻð��
GROUP BY 
invce_yymm,--equip_model_no, equip_model_nm,
case
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end

	

-- ���ű⺰ ������ û������ ��ȸ 
-- ��ݵ�� ��ȸ, VOD ������ û������ ��ȸ  ��ǰ��, �����ںм�, �Ϻ� ���� ���� �Ѿ׺��� �۰� ���� 
select 
���ؿ�,
���ű�з�,
case when ���ɴ� between '0' and '99' then 
	case when ���ɴ� between 0 and 29  then '20������'
	     when ���ɴ� between 30 and 39  then '30��'
	     when ���ɴ� between 40 and 49  then '40��' 
	     when ���ɴ� between 50 and 59  then '50��'
	     when ���ɴ� between 60 and 69 then '60��'
	     when ���ɴ� >= 70 then '70���̻�'
	 else  '-'
	 end
 else  '-'	  
end ���ɴ�,
sum(���ű⺰�����׸���),
sum(�����ڼ�)
from (
SELECT/*+ use_hash (c a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
--equip_model_no, equip_model_nm,
	case
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�,
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
	,'--') ���ɴ�,	
Sum(invce_amt)-Sum(disc_amt) ���ű⺰�����׸��� ,
count(c.scrbr_no) �����ڼ�
FROM chrg_info a,  cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, MMAA04T01 g, prdt_fix_chrg h
WHERE invce_yymm = '201905' -- û���� 
And invce_type_cd = 'R'  --�߰�
And invce_seq_no = 1 --�߰�
and a.chrg_item_cd = h.chrg_item_cd
and h.prdt_cd = g.prdt_cd
and g.prdt_type_cd in ('25','26')
and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and a.scrbr_no = e.scrbr_no
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < invce_yymm  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > invce_yymm  -- ���űⱳü�� �ֹ��Ͻð��
GROUP BY 
invce_yymm,--equip_model_no, equip_model_nm,
case
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
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
���ؿ�,
���ű�з�,
case when ���ɴ� between '0' and '99' then 
	case when ���ɴ� between 0 and 29  then '20������'
	     when ���ɴ� between 30 and 39  then '30��'
	     when ���ɴ� between 40 and 49  then '40��' 
	     when ���ɴ� between 50 and 59  then '50��'
	     when ���ɴ� between 60 and 69 then '60��'
	     when ���ɴ� >= 70 then '70���̻�'
	 else  '-'
	 end
 else  '-'	  
end

	


-- 2018092 ��ǰ ���嵿�� sky17 ��ǰ  û���ݾ� ��ȸ
SELECT /*+ USE_HASH(b a) */   
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,  
a.prdt_cd ��ǰ�ڵ�,
b.prdt_nm ��ǰ�ڵ��,
sum(a.invce_amt-a.disc_amt) ����,
count(a.scrbr_no) �����ڼ�
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







-- VOD ������ ���� , ī��, �޴���, ����Ʈ  , ������ ��û                                                     
select   
substr(�����Ͻ�,1,6) ��,���ű�з�, ��������, sum(PREPAY_AMT)+ sum(pnt_amt) �������ݾ�, sum(usg_amt) ����                                                           
from (                                                                                         
select                                                                                         
b.scrbr_no ���԰���ȣ, b.scrbr_nm ���԰���,a.sc_id ,                                         
usg_amt,PREPAY_AMT ,    pnt_amt,                                                                               
buy_dh �����Ͻ�, d.cd_nm ��������,                                                             
a.vod_id,c.title, main_cate_nm , sub_cate_nm , CONTENTS_CATE, CP_NM, DISTR_CMPY, PRDT_CMPY ,
case 
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
end ���ű�з�    
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
and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��                                                                 
) group by substr(�����Ͻ�,1,6) ,���ű�з�, ��������
    

	
-- ��ǰ�� ���� PPV û�����
select 
'����' ����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
substr(d.chl_nm,1,2), d.chl_no,
round(sum(won_occur_amt) - sum(won_occur_amt * (b.disc_amt/nullif(invce_amt,0))),0)  ����PPVû���ݾ�, 
count(distinct a.scrbr_no) �̿��ڼ�, count(*) �ֹ���
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


-- ��ǰ�� OTS PPV û����� 
select 
'OTS' ����,
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
substr(d.chl_nm,1,2), d.chl_no,
sum(chrg_amnt)	OTSû������	,
count(distinct a.scrbr_no) �̿��ڼ�, count(*) �ֹ���
from bilng_txn_info	a	, mmab03t01@LN_SCISCM_MM c, mmag02t01@LN_SCISCM_weblogic d
where invce_yymm  >= '201902' and a.invce_yymm <= '201907'
and unit_svc_cd = 'KTPPV'	
and to_char(a.BRDCST_FR_DH,'yyyymmddhh24miss') = c.svc_open_dh 
and a.PPV_SVC_ID = c.ppv_svc_id
AND c.chl_no = d.chl_no
AND c.svc_open_dh BETWEEN d.adpt_fr_dt AND d.adpt_to_dt
AND d.vtrl_chl_yn = '1'
group by  a.invce_yymm, substr(d.chl_nm,1,2),  d.chl_no

-- VOD ī�װ���������û���ݾ�
select 
-- a.invce_yymm û����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
c.CONTENTS_CATE,
--count(distinct a.scrbr_no)  ����ڼ�,
--sum(chrg_amnt) �ݾ�,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û�����αݾ�,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û���ݾ�  
from BILNG_TXN_INFO a, CHRG_INFO b, mmab06t01@LN_SCISCM_MM c  
where a.invce_yymm >= '201802' and a.invce_yymm <= '201802'
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '201802' and a.invce_yymm <= '201802'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.vod_id(+)
group by a.invce_yymm, c.CONTENTS_CATE


-- ��۽�������Ȳ�� �ڷ����� cp�з��� ���� 
select
--CONTENTS_CATE,  b.cp_nm,
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end �������з�,
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
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%�����%'	
	and buy_type_cd ='1'  -- ������ ���ŰǸ� 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%'
					)
	group by --CONTENTS_CATE, b.cp_nm 				
	case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end


-- ��۽�������Ȳ�� �ڷ����� cp�з��� û������  
select 
-- a.invce_yymm û����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end �������з�,
--c.CONTENTS_CATE,
--count(distinct a.scrbr_no)  ����ڼ�,
--sum(chrg_amnt) �ݾ�,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û�����αݾ�,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û���ݾ�  
from BILNG_TXN_INFO a, CHRG_INFO b, mmab06t01@LN_SCISCM_MM c  
where a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and a.unit_svc_cd = 'VOD' 
and a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and b.unit_svc_cd = 'VOD' 
and a.scrbr_no = b.scrbr_no  
and a.invce_yymm = b.invce_yymm
and a.PPV_SVC_ID = c.vod_id(+)
group by a.invce_yymm, -- c.CONTENTS_CATE
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end



-- VOD ������ ����, 2019.3�� ������ 
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
b.prdt_nm,
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201907'  
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm  , b.prdt_nm


-- ��۽�������Ȳ�� �ڷ����� cp�з��� ������ ���� 
select /*+ USE_HASH(b a) */    
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%������%' then '������'
	 when prdt_nm like '%CJ%' or prdt_nm like '%���Ϲ���%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'	 
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%ĳġ��%' then '��ȭ'
	 else '��Ÿ'
end ����,
b.prdt_nm �����׻�ǰ��,
sum(invce_amt-disc_amt)  VOD������û������ 
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201802' and a.invce_yymm <= '201901'
and a.invce_type_cd = 'R' 
AND a.invce_seq_no = 1    
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by invce_yymm ,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%������%' then '������'
	 when prdt_nm like '%CJ%' or prdt_nm like '%���Ϲ���%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'	 
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%ĳġ��%' then '��ȭ'
	 else '��Ÿ'
end , 
b.prdt_nm
order by 3,4
