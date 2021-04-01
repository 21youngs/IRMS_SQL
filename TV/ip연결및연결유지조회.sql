
-- 수신기별 VOD 사용자 
select
mm,
   case 
	   when equip_model_nm like '%안드로이드%' then '안드로이드'
	   else 'UHD/HD'
	end 수신기분류,
	equip_model_nm,equip_model_no,
	count(distinct scrbr_no)
	,sum(usg_amt)
from (
select 
	substr(a.BUY_DH,1,6) mm,   a.scrbr_no , equip_model_nm,equip_model_no, a.usg_amt
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f
	where a.VOD_ID = b.vod_id 
	and a.buy_dh between '20180701' and '20180731'||'999999'
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
)group by 	mm,
   case 
	   when equip_model_nm like '%안드로이드%' then '안드로이드'
	   else 'UHD/HD'
	end,
	equip_model_nm, equip_model_no
	

-- 수신기유지수 
select substr(dt,1,6) 월, 
case 
	   when equip_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when equip_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end 분류, --a.equip_model_no,
 sum(a.MAIN_CNT) 유지수
from mmec50t01 a, mmda03t01 b , zzaa02t01 c
where dt in ('20200629')
and a.equip_model_no = b.equip_model_no
and b.stb_grp_cd = c.cd
and c.cd_cl ='MM083'
and IP_YN ='0'
and c.cd_nm not like '%OTS%'
--and CAS_TYPE_CD ='2'
-- AND B.equip_model_nm like '%UHD%'
group by substr(dt,1,6),
case 
	   when equip_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when equip_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end
--, a.equip_model_no



select substr(nalja,1,6),  sum(cnt)
from aptest.ip_callback_report
where nalja in ('20180630')
and gubun = '연결유지'
group by substr(nalja,1,6)

select substr(nalja,1,6),  sum(cnt)
from aptest.ip_callback_report
where nalja in ('20180531')
and gubun = '연결이력'
group by substr(nalja,1,6)


--IP 연결 유지 현황 최종 ( 강석진 ) 
select x.nalja , x.cnt, y.cnt ip_active, x.cnt-y.cnt ip_inactive
from
(
select nalja, count(*) cnt from aptest.ip_callback_new_report 
where nalja in ('20180930','20180831','20180731','20180630','20180531','20180430','20180331','20180228','20180131') and gubun='연결이력'
group by nalja
) x,
(
select nalja, count(*) cnt from aptest.ip_callback_new_report 
where nalja in ('20180930','20180831','20180731','20180630','20180531','20180430','20180331','20180228','20180131') and gubun='연결유지'
group by nalja
) y
where x.nalja = y.nalja



-- 수신기 유지수 
select substr(dt,1,6) 월, 
 sum(a.MAIN_CNT) 유지수
from mmec50t01 a, mmda03t01 b , zzaa02t01 c
where dt in ('20200629') 
and a.equip_model_no = b.equip_model_no
and b.stb_grp_cd = c.cd
and c.cd_cl ='MM083'
and IP_YN ='0'
and c.cd_nm not like '%OTS%'
group by  
substr(dt,1,6)  





select * 
from aptest.ip_callback_new_report 
where nalja in ('20180531') and gubun='연결이력'

select order_type, count(*) 
from aptest.ip_callback_new_report 
where nalja in ('20180531') and gubun='연결이력'
group by order_type

select * 
from aptest.ip_callback_new_report 
where nalja in ('20180630') and gubun='연결유지'


select nalja,  count(*) cnt 
from aptest.ip_callback_new_report 
where nalja in ('20180630') and gubun='연결유지'
group by nalja

-- 수신기별 연결유지 
select nalja, STB_MODEL_NM, count(*) cnt 
from aptest.ip_callback_new_report 
where nalja in ('20191031') and gubun='연결유지'
group by nalja, STB_MODEL_NM


-- 수신기별 연결유지 
select nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end 분류, 
--b.equip_model_no,STB_MODEL_NM, 
count(*) cnt 
from aptest.ip_callback_new_report  a, mmda03t01 b
where nalja in ('20200628') and gubun='연결유지'
and a.STB_MODEL_NM = b.equip_model_nm
group by nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end
--,b.equip_model_no,STB_MODEL_NM


 ( /* 월말 구하기 */
			select max(dt) dd , mm                                  
			from (                               
				select dt, substr(dt,1,6) mm 
				from mmec18t01               
				where dt > '201801'  
				group by dt, substr(dt,1,6)) 
			group by mm); 
			

--안드로이드수신기ipactive
select nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end 분류,  count(*) cnt 
from aptest.ip_callback_new_report  a, mmda03t01 b,
                 ( /* 월말 구하기 */
                    select max(dt) dt , mm                                  
                    from (                               
                        select dt, substr(dt,1,6) mm 
                        from mmec18t01               
                        where dt > '20190101'  
                        group by dt, substr(dt,1,6)) 
                    group by mm)  d 
where nalja = d.dt 
and gubun='연결유지'
and a.STB_MODEL_NM = b.equip_model_nm
and STB_MODEL_NM like '%안드로이드%' 
group by nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end	
			
			

select * from mmda03t01 
where equip_model_nm like '%UHD%'

select * from mmda03t01 
where equip_model_nm like '%안드로이드%'


-- 수신기별 연결유지 와 월정액 가입수 
select nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end 분류, 
STB_MODEL_NM, count(*) cnt, sum(decode( c.scrbr_no,'',0,cnt)) 
from aptest.ip_callback_new_report  a, cmcc04t01 b, 
 ( select scrbr_no,STB_SEQ_NO, count(*) cnt from cmcc03t01 
where sVC_OPEN_DH < '20180627'
and nvl(rscs_dh,'29991231') > '20180627' 
group by scrbr_no, STB_SEQ_NO) c 
where nalja in ('20180627') and gubun='연결유지'
and a.SCRBR_NO = b.scrbr_no
and a.sc_id = b.sc_id
and b.SVC_OPEN_DH < '20180627'
and nvl(b.rscs_dh,'29991231') > '20180627'
and b.SCRBR_NO = c.scrbr_no(+)
and b.seq_no = c.STB_SEQ_NO(+)
group by nalja, 
case 
	   when STB_MODEL_NM like '%안드로이드%' then '안드로이드'
	   when STB_MODEL_NM like '%UHD%' then 'UHD'
	   else 'HD'
end,
STB_MODEL_NM


select scrbr_no,STB_SEQ_NO, count(*) cnt from cmcc03t01 
where sVC_OPEN_DH < '20180627'
and nvl(rscs_dh,'29991231') > '20180627' 
group by scrbr_no, STB_SEQ_NO


select  count(*) cnt from cmcc03t01 
where sVC_OPEN_DH < '20180627'
and nvl(rscs_dh,'29991231') > '20180627' 



SELECT 
*
FROM 
cmcc03t01 x 
WHERE X.SVC_OPEN_DH < '20180628'
and nvl(x.rscs_dh,'29991231') > '20180628'




-- vod 사용자수 
select
--substr(buy_dh,1,6) 월,
수신기분류,
equip_model_no,
count(distinct scrbr_no) vod전체사용자수,
count(distinct decode(buy_type_cd, '1', scrbr_no)) 유료VOD사용자수, 
count(distinct scrbr_no)  - count(distinct decode(buy_type_cd, '1', scrbr_no)) 무료VOD사용자수
from (
select a.buy_dh, title,
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'dy') 요일, 
	to_char(to_date(substr(buy_dh ,1, 8),'yyyymmdd'),'iw') 주차,
		case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	end 수신기분류,
	f.equip_model_no,
	usg_amt 금액, 
	case when substr(c.SVC_OPEN_DH,1,6) =  substr(a.buy_dh,1,6) then '신규가입자'
     else '기존가입자' 
    end 신규가입자구분, 
	buy_type_cd,
	a.scrbr_no 
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between '20190101' and '20190531'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'	
	and e.mst_file_stat_cd ='1'   -- 현재유지가입자만 
	--and buy_type_cd ='1'  -- 종량제 구매건만 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
)group by --substr(buy_dh,1,6),
수신기분류,equip_model_no


select * 
from cmcc01t01 a, mmaa25t01 b
where a.entr_pkg_grade_cd = b.ENTR_PKG_GRADE_CD
and a.MST_FILE_STAT_CD ='1'



select 수신기분류,  chl_info		, count(distinct scrbr_no)
from (
select a.buy_dh, g.chl_info, a.scrbr_no ,
 	   case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	   end 수신기분류
	from cmcb15t01 a, MMAB06T01 b, cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, mmaa25t01 g
	where a.VOD_ID = b.vod_id(+) 
	and a.buy_dh between '20180501' and '20180531'||'999999'
	and a.scrbr_no = c.scrbr_no
	and c.cust_no = d.cust_no
	and nvl(a.cncl_yn,'N') = 'N'
	and a.scrbr_no = e.scrbr_no
	and a.sc_id = e.sc_id
	and e.stb_model_no = f.equip_model_no	and e.SVC_OPEN_DH < a.buy_dh  -- 수신기교체자 주문일시고려
    and nvl(e.RSCS_DH,'29991231') > a.buy_dh  -- 수신기교체자 주문일시고려
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'
	and c.ENTR_PKG_GRADE_CD = g.ENTR_PKG_GRADE_CD	
	and c.SVC_OPEN_DH  between '20180501' and '20180531'||'999999'
	and buy_type_cd ='1'  -- 종량제 구매건만 
	and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)
)group by 수신기분류 ,chl_info				


select * from cm

select 
case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	   end 수신기분류,
chl_info, count(*)
from cmcc01t01 c , cmaa01t01 d, cmcc04t01 e, mmda03t01 f, mmaa25t01 g
where  c.cust_no = d.cust_no
and c.scrbr_no = e.scrbr_no
and e.MST_FILE_STAT_CD ='1'
	and e.stb_model_no = f.equip_model_no
	and sale_type_cd = '1'
	and c.scrbr_nm not like '%사업용%'
	and c.ENTR_PKG_GRADE_CD = g.ENTR_PKG_GRADE_CD	
	and c.SVC_OPEN_DH  between '20180501' and '20180531'||'999999'
	group by 	case 
	   when f.equip_model_nm like '%안드로이드%' then '안드로이드'
	   when f.equip_model_nm like '%UHD%' then 'UHD'
	   else 'HD'
	   end, chl_info	

	   
-- 사업용 가입자 
(select  from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and a.buy_dh between substr(x.svc_open_dh,1,6) and nvl(x.rscs_dh,'9')
					and y.event_nm like '%사업용%'
					)	 
					
					  
select setl_etps_cd from mmab06t01
where sub_cate_nm like '%아시아%'

-- IP연결고객대상 TM추출
select --a.sido_type, a.SIGUNGU_TYPE	, stb_model_nm, 
/*
(select distinct decode(x.scrbr_no,'','','중드일드시청경험')
from cmcb15t01 x, mmab06t01 y
where a.scrbr_no = x.scrbr_no
and x.vod_id = y.vod_id
and x.buy_dh > '20200101'
and y.SETL_ETPS_CD in (select setl_etps_cd from mmab06t01
                            where sub_cate_nm like '%아시아%')
group by decode(x.scrbr_no,'','','중드일드시청경험')
) 중드일드시청경험,*/
d.cust_no, d.cust_nm, JUMIN_BIZ_NO,
DECODE (length(JUMIN_BIZ_NO),7, 
	to_char(trunc((to_number('2020')- 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2))))))))))))))))))/10)*10),'-')
from aptest.ip_callback_new_report  a, mmda03t01 b, cmcc01t01 c, cmaa01t01 d
where nalja = '20200705'
and gubun='연결유지'
and a.STB_MODEL_NM = b.equip_model_nm
and STB_MODEL_NM like '%안드로이드%' 
and a.scrbr_no = c.scrbr_no
and c.cust_no = d.cust_no
and c.mst_file_stat_Cd ='1'
and not exists (select 1 from cmcd01t01 x, mmaj01t01 y 
	                where x.event_no = y.event_no and y.event_use_type in ('4','5')
	                and a.scrbr_no = x.scrbr_no
					and y.event_nm like '%사업용%'
					)
and  DECODE (length(JUMIN_BIZ_NO),7, 
	to_char(trunc((to_number('2020')- 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2))))))))))))))))))/10)*10),'-')  > '39'
group by -- a.sido_type, a.SIGUNGU_TYPE	, stb_model_nm, 
	d.cust_no, d.cust_nm, JUMIN_BIZ_NO,
DECODE (length(JUMIN_BIZ_NO),7, 
	to_char(trunc((to_number('2020')- 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'1','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'2','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'3','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2), 
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'4','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'5','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'6','19'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'7','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2),
	(DECODE(SUBSTR(JUMIN_BIZ_NO,7,1),'8','20'||SUBSTR(JUMIN_BIZ_NO, 1, 2))))))))))))))))))/10)*10),'-')
					
					
					
