CREATE OR REPLACE FUNCTION public.dpp_data_convert(dateinput character varying)
 RETURNS date
 LANGUAGE plpgsql
AS $function$
	DECLARE vDate VARCHAR(50);
	DECLARE vAno VARCHAR(4);
	declare vMes VARCHAR(10);
	declare vDia VARCHAR(2);
	declare vPart VARCHAR(50);
	DECLARE vStartingIndex INT = 0;
BEGIN

	vDate := REPLACE(dateinput, ' ', '');

	if vDate is null or trim(vDate) = '' then
		return null;
	end if;

	select case 
				when POSITION('.' in vDate) > 0 then POSITION('.' in vDate)
				when POSITION('/' in vDate) > 0 then POSITION('/' in vDate)
				when POSITION('-' in vDate) > 0 then POSITION('-' in vDate)
			else 0 end into vStartingIndex;

	IF (vStartingIndex = 0) and length(vDate) = 10 then
		IF (public.dpp_isdate(SUBSTRING(vDate, 7, 4)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 1, 2))) then
			RETURN CAST(SUBSTRING(vDate, 7, 4)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 1, 2) as DATE);
		ELSEIF (public.dpp_isdate(SUBSTRING(vDate, 1, 4)||'-'||SUBSTRING(vDate, 6, 2)||'-'||SUBSTRING(vDate, 9, 2))) then
			RETURN CAST(SUBSTRING(vDate, 1, 4)||'-'||SUBSTRING(vDate, 6, 2)||'-'||SUBSTRING(vDate, 9, 2) as DATE);
		ELSEIF (public.dpp_isdate(SUBSTRING(vDate, 7, 2)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 1, 2))) then
			RETURN CAST(SUBSTRING(vDate, 7, 2)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 1, 2) as DATE);
		ELSEIF (public.dpp_isdate(SUBSTRING(vDate, 1, 2)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 7, 2))) then
			RETURN CAST(SUBSTRING(vDate, 1, 2)||'-'||SUBSTRING(vDate, 4, 2)||'-'||SUBSTRING(vDate, 7, 2) as DATE);
		ELSE
			RETURN null;
		end if;
	elseif (vStartingIndex = 0) then
		if public.dpp_isint(right(vDate, 4)) and cast(right(vDate, 4) as int) > 1900 then
			if length(vDate) = 6 then
				IF (public.dpp_isdate(SUBSTRING(vDate, 3, 4)||'-0'||SUBSTRING(vDate, 2, 1)||'-0'||SUBSTRING(vDate, 1, 1))) then
					return CAST(SUBSTRING(vDate, 3, 4)||'-0'||SUBSTRING(vDate, 2, 1)||'-0'||SUBSTRING(vDate, 1, 1) as DATE);
				else
					return null;
				end if;
			elseif length(vDate) = 7 then
				if cast(SUBSTRING(vDate, 2, 2) as int) < 13 then
					IF (public.dpp_isdate(SUBSTRING(vDate, 4, 4)||'-'||SUBSTRING(vDate, 2, 2)||'-0'||SUBSTRING(vDate, 1, 1))) then
						return CAST(SUBSTRING(vDate, 4, 4)||'-'||SUBSTRING(vDate, 2, 2)||'-0'||SUBSTRING(vDate, 1, 1) as DATE);
					else
						return null;
					end if;
				else
					IF (public.dpp_isdate(SUBSTRING(vDate, 4, 4)||'-0'||SUBSTRING(vDate, 3, 1)||'-'||SUBSTRING(vDate, 1, 2))) then
						return CAST(SUBSTRING(vDate, 4, 4)||'-0'||SUBSTRING(vDate, 3, 1)||'-'||SUBSTRING(vDate, 1, 2) as DATE);
					else
						return null;
					end if;
				end if;
			elseif length(vDate) = 8 then
				IF (public.dpp_isdate(SUBSTRING(vDate, 5, 4)||'-'||SUBSTRING(vDate, 3, 2)||'-'||SUBSTRING(vDate, 1, 2))) then
					return CAST(SUBSTRING(vDate, 5, 4)||'-'||SUBSTRING(vDate, 3, 2)||'-0'||SUBSTRING(vDate, 1, 2) as DATE);
				else
					return null;
				end if;
			end if;
		elseif public.dpp_isint(left(vDate, 4)) and cast(left(vDate, 4) as int) > 1900 then
			return null;
		end if;
	end IF;

	select SUBSTRING(vDate, 1, (case when vStartingIndex <= 0 then 0 else vStartingIndex-1 end)) into vPart;

	IF (LOWER(vPart) IN ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', /*ingles*/'feb', 'apr', 'may', 'aug', 'sep', 'oct', 'nov', 'dec')) then
		select CASE  
						WHEN LOWER(vPart) = 'jan' THEN '01'
						WHEN LOWER(vPart) in ('fev', 'feb') THEN '02'
						WHEN LOWER(vPart) = 'mar' THEN '03'
						WHEN LOWER(vPart) in ('abr', 'apr') THEN '04'
						WHEN LOWER(vPart) in ('mai', 'may') THEN '05'
						WHEN LOWER(vPart) = 'jun' THEN '06'
						WHEN LOWER(vPart) = 'jul' THEN '07'
						WHEN LOWER(vPart) in ('ago', 'aug') THEN '08'
						WHEN LOWER(vPart) in ('set', 'sep') THEN '09'
						WHEN LOWER(vPart) in ('out', 'oct') THEN '10'
						WHEN LOWER(vPart) = 'nov' THEN '11'
						WHEN LOWER(vPart) in ('dec', 'dez') THEN '12'
						ELSE ''
					end into vMes;
	ELSEIF (public.dpp_isint(vPart) and vPart::int BETWEEN 1 AND 31) then
		vDia := RIGHT('0'||vPart, 2);
	ELSEIF (public.dpp_isint(vPart)) then
		vAno := vPart;
	ELSE 
		RETURN NULL;
	end IF;

	vDate := SUBSTRING(vDate, vStartingIndex+1, length(vDate));
	
	select  case 
			when POSITION('.' in vDate) > 0 then POSITION('.' in vDate)
			when POSITION('/' in vDate) > 0 then POSITION('/' in vDate)
			when POSITION('-' in vDate) > 0 then POSITION('-' in vDate)
		else 0 end into vStartingIndex;

	select SUBSTRING(vDate, 1, (case when vStartingIndex <= 0 then 0 else vStartingIndex-1 end)) into vPart;

	IF (LOWER(vPart) IN ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', /*ingles*/'feb', 'apr', 'may', 'aug', 'sep', 'oct', 'nov', 'dec')) then
		select CASE  
						WHEN LOWER(vPart) = 'jan' THEN '01'
						WHEN LOWER(vPart) in ('fev', 'feb') THEN '02'
						WHEN LOWER(vPart) = 'mar' THEN '03'
						WHEN LOWER(vPart) in ('abr', 'apr') THEN '04'
						WHEN LOWER(vPart) in ('mai', 'may') THEN '05'
						WHEN LOWER(vPart) = 'jun' THEN '06'
						WHEN LOWER(vPart) = 'jul' THEN '07'
						WHEN LOWER(vPart) in ('ago', 'aug') THEN '08'
						WHEN LOWER(vPart) in ('set', 'sep') THEN '09'
						WHEN LOWER(vPart) in ('out', 'oct') THEN '10'
						WHEN LOWER(vPart) = 'nov' THEN '11'
						WHEN LOWER(vPart) in ('dec', 'dez') THEN '12'
						ELSE ''
					end into vMes;
	ELSEIF (public.dpp_isint(vPart) and vPart::int BETWEEN 1 AND 12) and vMes is null then
		vMes := RIGHT('0'||vPart, 2);
	ELSEIF (public.dpp_isint(vPart) and vPart::int BETWEEN 1 AND 31) and vDia is null then
		vDia := RIGHT('0'||vPart, 2);
	ELSEIF (public.dpp_isint(vPart)) then
		vAno := vPart;
	ELSE 
		RETURN NULL;
	end if;

	vPart := SUBSTRING(vDate, vStartingIndex+1, length(vDate));

	IF (LOWER(vPart) IN ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', /*ingles*/'feb', 'apr', 'may', 'aug', 'sep', 'oct', 'nov', 'dec')) then
		select CASE  
						WHEN LOWER(vPart) = 'jan' THEN '01'
						WHEN LOWER(vPart) in ('fev', 'feb') THEN '02'
						WHEN LOWER(vPart) = 'mar' THEN '03'
						WHEN LOWER(vPart) in ('abr', 'apr') THEN '04'
						WHEN LOWER(vPart) in ('mai', 'may') THEN '05'
						WHEN LOWER(vPart) = 'jun' THEN '06'
						WHEN LOWER(vPart) = 'jul' THEN '07'
						WHEN LOWER(vPart) in ('ago', 'aug') THEN '08'
						WHEN LOWER(vPart) in ('set', 'sep') THEN '09'
						WHEN LOWER(vPart) in ('out', 'oct') THEN '10'
						WHEN LOWER(vPart) = 'nov' THEN '11'
						WHEN LOWER(vPart) in ('dec', 'dez') THEN '12'
						ELSE ''
					end into vMes;
	ELSEIF (public.dpp_isint(left(vPart,4))) and vAno is null then
		vAno := left(vPart, 4);
	elseif (public.dpp_isint(left(vPart, 2))) then
		vDia := RIGHT('0'||trim(left(vPart,2)), 2);
	else
		RETURN NULL;
	end if;

	IF (public.dpp_isdate(vAno||'-'||vMes||'-'||vDia)) then
		RETURN cast((vAno||'-'||vMes||'-'||vDia) as date);		
	end if;

	return null;
end;
$function$
;