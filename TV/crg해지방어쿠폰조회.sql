-- VOD ������ ���Ű� 
select 
'VOD' ��ǰ����,
buy_dh �����Ͻ�, sc_id ����Ʈī���ȣ , a.vod_id,c.title, 
--AF_INVCE_YN,
--AF_INVCE_AMT,   
PAY_TRNSN_ID , 
b.scrbr_nm ���԰���, 
--b.sale_type_cd ,
'����' ���Ա���, 
case when b.sale_type_cd = '2' or scrbr_nm like '%�����%' then '�����' 
end ����뱸��,
d.cd_nm ��������,
--usg_amt "����(�ΰ�������)",
--trunc(PRDT_PRCE*1.1,-1) "����(�ΰ�������)", 
--trunc(PREPAY_AMT*1.1,-1) "�������ݾ�(�ΰ�������)",
trunc(PREPAY_AMT*1.1,-1) "����ݾ�(�ΰ�������)",
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
substr(������,1,6),
pay_mth_cd,
count(distinct scrbr_no) �̿��ڼ�,
count(*) �ֹ��Ǽ�, 
sum(usg_amt) ����,
sum(AF_INVCE_AMT) û������,
sum(PREPAY_AMT+PNT_AMT) ����������
from (
	select substr(buy_dh ,1, 8) ������, title,
	--decode(g.scrbr_no,'','','��Ƽ��') ��Ƽ�뿩��,
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'dy') ����, 
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'iw') ����, 
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
)group by substr(������,1,6),pay_mth_cd



-- VOD  ������ ������ ����                                                      
select  substr(�����Ͻ�,1,6),  pay_mth_cd, sum(PREPAY_AMT), sum(PNT_AMT), sum(usg_amt)                                                           
from (                                                                                         
select                                                                                         
sc_id ,                                         
usg_amt,                                                                                       
PREPAY_AMT , 
PNT_AMT,                                                                                  
buy_dh �����Ͻ�,   pay_mth_cd                                                        
from cmcb15t01 a                                     
where  buy_dh like '202001%' -- ��������                                                                    
--and af_invce_yn ='N'                                                                         
--and (a.prepay_amt <> 0 or pnt_amt <> 0 ) 
and nvl(a.cncl_yn,'N') = 'N'
and PAY_TRNSN_ID is not null                                                                             
) group by substr(�����Ͻ�,1,6), pay_mth_cd

select * from zzba03t01 where sys_auth_nm like '%�ý���%'

insert into zzba03t01 (USER_ID, SYS_AUTH_NM,  REGR_DT, REGR_USER_ID)
values ('01176','�ý��ۿ����','20200819','01141')

commit;

SELECT * FROM ZZAA02T01 WHERE CD_CL ='CM454'
and CD_nm like '����%' 

SELECT * FROM ZZAA02T01 WHERE CD_CL ='CM454'
and '20200819' between adpt_fr_Dt and adpt_to_dt
and cd_eng_nm is not null
order by cd_desc desc 

SELECT * FROM ZZAA02T01 WHERE CD='E01A1000006' and CD_CL ='CM454'


SELECT * FROM ZZAA02T01 WHERE CD_nm like '���� VOC 100%' 

select * from cmcb19t01 a, zzaa02t01 b
where a.COUPON_CD = b.CD
and b.cd_cl ='CM454'
--and g.cd_eng_nm in (435,436,437) 
--and h.COUPON_CD in ('E01A0500001', 'E01A1000002', 'E03A1000003')


-- crg ������볻�� ��ȸ 
select 
    substr(buy_dh ,1, 8) ������,
    COUPON_ISSUE_CD �����ڵ�,
    case  when COUPON_ISSUE_CD = '67' then '�ű�'  
      when COUPON_ISSUE_CD = '127' then '��ü'  
      when COUPON_ISSUE_CD = '134' then '����'  
      when COUPON_ISSUE_CD = '160' then 'AS'  
      when COUPON_ISSUE_CD = '435' then 'CRG 5õ��'  
      when COUPON_ISSUE_CD = '436' then 'CRG 1����'  
      when COUPON_ISSUE_CD = '437' then 'CRG 1����(dps)'  
      when COUPON_ISSUE_CD is not null then '��Ÿ'
end ��������,
 decode(a.DISC_AMT,0,'������','', '������', decode(COUPON_ISSUE_CD,'','skyA����','��������')) �������ο���,
     title,a.VOD_ID,
		case 
	   when f.equip_model_nm like '%�ȵ���̵�%' then '�ȵ���̵�'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end ���ű�з�,
	a.PRDT_PRCE ����,
	a.DISC_AMT ����,	
	AF_INVCE_AMT û���ݾ�,
	usg_amt ����, 
	AF_INVCE_YN û������,
	round(a.DISC_AMT / a.PRDT_PRCE *100,0) ������,
	a.scrbr_no ���԰���ȣ, scrbr_nm ���԰���, a.sc_id , 
	h.REGR_USER_ID
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f,  cmcb19t01 h
	where a.VOD_ID = b.vod_id
	and a.buy_dh between '20200101' and '20200331'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- ���űⱳü�� �ֹ��Ͻð��
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%�����%'	
	and buy_type_cd ='1'  -- ������ ���ŰǸ� 
	and a.DISC_AMT > 0   -- ���εȰ�
	--AND COUPON_ISSUE_CD in (435,436,437) -- CRG
	and a.SCRBR_NO = h.scrbr_no(+)
	and a.sc_id = h.sc_id(+)
	and decode(a.COUPON_ISSUE_CD, 435,'E01A0500001', 436,'E01A1000002', 437,'E03A1000003', 'E01F1000001') 	 = h.COUPON_CD
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%�����%'
					)