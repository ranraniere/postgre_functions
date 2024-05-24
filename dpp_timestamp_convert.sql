CREATE OR REPLACE FUNCTION public.dpp_timestamp_convert(dateinput character varying)
 RETURNS timestamp without time zone
 LANGUAGE plpgsql
AS $function$
	declare vTime time;
	declare vDateConv date;
	declare vRetorno timestamp;
	declare vPart1 varchar(50);
	declare vPart2 varchar(50);
begin
	dateinput := REPLACE(REPLACE(dateinput, 'T', ' '), 'Z','');
	select split_part(dateinput, ' ', 1) into vPart1;
	select split_part(dateinput, ' ', 2) into vPart2;

	if vPart1 is null or trim(vPart1) = '' then 
		return null;
	end if;
	
	select public.dpp_data_convert(vPart1) into vDateConv;
	vTime := vPart2::time;

	if vDateConv is null then
		return null;
	end if;

	select vDateConv::timestamp + vTime into vRetorno;
	return vRetorno;
exception when others then
	return null;
end;
$function$
;