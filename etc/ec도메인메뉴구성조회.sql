-- 메뉴구성 일괄 조회 
select
a.DOMAIN_ID,L 레벨, 
substr(a.MENU_ID,1,2)m1,
substr(a.MENU_ID,3,2)m2,
substr(a.MENU_ID,5,2)m3,
substr(a.MENU_ID,7,2)m4,
substr(a.MENU_ID,9,2)m5, 
LPAD('  ', 4*(a.l - 1))||a.menu_nm MENU_NM, a.MENU_ID,  a.UPPR_MENU_ID, a.SORT_ORDER, a.TOP_MENU_YN,  
b.view_id view_code, b.view_NM view_nm
from (
	select a.DOMAIN_ID, level l, a.menu_nm , a.menu_id , a.uppr_menu_id , a.TOP_MENU_YN, a.SORT_ORDER, a.view_id
	from  zzba22t01 a 
	where domain_id = 'ec' 
	start with a.uppr_menu_id = '0000'  and a.domain_id = 'ec'
	connect by prior a.menu_id = a.uppr_menu_id and a.domain_id = 'ec'  --and level > 1
	order SIBLINGS BY a.SORT_ORDER
) a , 
(
   select *
    from zzba19t01 x 
    where x.use_yn = 'Y'
	and OLD_CONTENT_URL||NEW_CONTENT_URL is not null
) b
where a.view_id = b.view_id(+)	


-- 메뉴구성 일괄 조회 
select
a.DOMAIN_ID,L 레벨, 
substr(a.MENU_ID,1,2)m1,
substr(a.MENU_ID,3,2)m2,
substr(a.MENU_ID,5,2)m3,
substr(a.MENU_ID,7,2)m4,
substr(a.MENU_ID,9,2)m5, 
LPAD(' ', 2*(a.l - 1))||a.menu_nm MENU_NM, a.MENU_ID,  a.UPPR_MENU_ID, a.SORT_ORDER, a.TOP_MENU_YN,  
b.view_id view_code, b.view_NM view_nm
from (
	select a.DOMAIN_ID, level l, a.menu_nm , a.menu_id , a.uppr_menu_id , a.TOP_MENU_YN, a.SORT_ORDER, a.view_id
	from  zzba22t01 a 
	where domain_id = 'cs' 
	start with a.uppr_menu_id = '0000'  and a.domain_id = 'cs'
	connect by prior a.menu_id = a.uppr_menu_id and a.domain_id = 'cs'  --and level > 1
	order SIBLINGS BY a.SORT_ORDER
) a , 
(
   select *
    from zzba19t01 x 
    where x.use_yn = 'Y'
	and OLD_CONTENT_URL||NEW_CONTENT_URL is not null
) b
where a.view_id = b.view_id(+)	

select * from zzba22t01
where menu_nm ='개인고객등록'

select * from zzba19t01 x  where view_id ='1005'