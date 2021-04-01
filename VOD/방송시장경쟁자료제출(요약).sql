
-- 1. ������û������, 2.������ ����������, 3.������û�� ������ CP �з� �������� �����Ͽ� �����Ͽ� ��� �ջ�
-- �����Ʈ���� ����������(CP�з�����), �����׸���(CP�з�����) ���� ������ ��.

-- 1. ��۽�������Ȳ�� �ڷ����� cp�з��� û������, (���DB)
select
-- a.invce_yymm û����,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyy') ���ؿ���,
to_char(add_months(to_date(a.invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end �������з�,
c.cp_nm ,
--c.CONTENTS_CATE,
count(distinct a.scrbr_no)  ����ڼ�,
--sum(chrg_amnt) �ݾ�,
--round(sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û�����αݾ�,
round(sum(chrg_amnt) - sum(chrg_amnt * (b.disc_amt/nullif(invce_amt,0))),0) û���ݾ�
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
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end



-- 2. ��۽�������Ȳ�� �ڷ����� cp�з��� VOD ������ ������ ���� (��DB, �������ڷ�� ��ݿ� ����)
select  substr(�����Ͻ�,1,4) ���ؿ���,
substr(�����Ͻ�,1,6) ���ؿ�,
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end �������з�,
CP_NM,
count(distinct scrbr_no)  ����ڼ�,
sum(usg_amt)   �������ݾ�
from (
select
b.scrbr_no , b.scrbr_nm ���԰���,sc_id ,
usg_amt,
PREPAY_AMT ,
PNT_AMT,
buy_dh �����Ͻ�, d.cd_nm ��������,
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
) group by substr(�����Ͻ�,1,4), substr(�����Ͻ�,1,6) ,
CP_NM,
case when CONTENTS_CATE in ('������ �ٽú���') then '������'
     when CONTENTS_CATE in ('��ȭ', '���ο�ȭ') then '��ȭ'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'CJ ENM' then 'CJ �迭'
	 when CONTENTS_CATE in ('TV �ٽú���') and cp_nm in 'JTBC' then 'JTBC �迭'
	 else '��Ÿ'
end


-- 3. ��۽�������Ȳ�� �ڷ����� cp�з��� ������ ���� (���DB)
select /*+ USE_HASH(b a) */
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyy') ���ؿ�,
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm') ���ؿ�,
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%������%' then '������'
	 when prdt_nm like '%CJ%' or prdt_nm like '%���Ϲ���%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%ĳġ��%' then '��ȭ'
	 else '��Ÿ'
end ����,
b.prdt_nm �����׻�ǰ��,
count(distinct scrbr_no)  ����ڼ�,
sum(invce_amt-disc_amt)  VOD������û������
from CHRG_info a, MMAA04T01 b, prdt_fix_chrg c
where a.invce_yymm >= '201902' and a.invce_yymm <= '202101'
and a.invce_type_cd = 'R'
AND a.invce_seq_no = 1
and a.chrg_item_cd = c.chrg_item_cd
and c.prdt_cd = b.prdt_cd
and b.prdt_type_cd in ('25','26')
group by to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyy'),
to_char(add_months(to_date(invce_yymm,'yyyymm'),-1),'yyyymm'),
case when prdt_nm like '%MBC%' or prdt_nm like '%SBS%' or prdt_nm like '%KBS%' or prdt_nm like '%������%' then '������'
	 when prdt_nm like '%CJ%' or prdt_nm like '%���Ϲ���%'  then 'CJ'
	 when prdt_nm like '%JTBC%'  then 'JTBC'
	 when prdt_nm like '%PLAYY%' or prdt_nm like '%ĳġ��%' then '��ȭ'
	 else '��Ÿ'
end ,
b.prdt_nm
order by 3,4
