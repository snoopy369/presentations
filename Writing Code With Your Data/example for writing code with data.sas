%macro put_name(name=);
  data _null_;
    set sashelp.class;
    where name="&name.";
    put name=;
  run;
%mend put_name;


*use PROC SQL;
proc sql;
  select cats('%put_name(name=',name,')')
    into :namelist separated by ' '
    from sashelp.class;
quit;

%put %superq(namelist);


&namelist.;

*use CALL EXECUTE;

data _null_;
  set sashelp.class;
  callstr = cats('%put_name(name=',name,')');
  put callstr=;
  call execute(callstr);
run;



*use INCLUDE;
filename callfile temp;
data _null_;
  set sashelp.class;
  file callfile;
  callstr = cats('%put_name(name=',name,')');
  put callstr;
run;

%include callfile;
