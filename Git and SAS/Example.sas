*This is an example file to show how commits, push and pull work;

proc freq data=sashelp.class;
  tables age*height/list;
run;

*We added this below!;
proc means data=sashelp.class;
  var height weight;
  class age sex;
run;

*Github Added;
proc print data=sashelp.class;
run;
