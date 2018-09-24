%macro formatomatic(data=           /* source dataset - can include dataset options */,
                    start=          /* what to convert from - a variable or expression that evaluates to a value, for many-to-one mappings the starting point of the range */,
                    end=            /* blank to do nothing, or if what converting from is a range - a variable or expression that evaluates to a value for the ending value of the range*/,
                    to=             /* what to convert to - a value, variable, or expression that evaluates to a value */,
                    default=%str( ) /* the value to use when no match is found - a value, variable, or expression that evaluates to a value */,
                    mlf=            /* blank to do nothing, or 1 to enable multilabel formats */,
                    library=WORK    /* blank for WORK or the name of a previously defined SAS library where you want the format stored*/,
                    fmtname=        /* name of the format - a value, variable, or expression that evaluates to a value */,
                    type=           /* the type of the format (C or N) */,
                    dedup=          /* blank to do nothing, or 1 to dedup the dataset by FROM prior to creating the format */, 
                    debug=          /* 1 to preserve the interim datasets, or blank to delete them */
                   );

  data __for_fmt;
    set &data.;
    start=&start.;
    label=&to.;
    length hlo $3;
    retain fmtname "&fmtname.";
    hlo=' ';

   %if %length(&type)>0 %then %do;
    retain type "&type.";
   %end;

   %if %length(&mlf)>0 %then %do;
    hlo='m';
   %end;
   %if %length(&end)>0 %then %do;
    end=&end.;
   %end;
    output;
    if _n_=1 then do;
      hlo=cats('o',hlo);
      call missing(start);
      label="&default.";
      output;
    end;
  run;

  %if %length(&dedup)>0 %then %do;
    proc sort nodupkey data=__for_fmt;  
      by fmtname start;
    run;
  %end;
  
  proc format lib=&library. cntlin=__for_fmt;
  quit;
  
  %if %length(&debug) = 0 %then %do;
    proc datasets nolist nodetails;
      delete __for_fmt;
    quit;
  %end;

%mend formatomatic;

/* Example usage

   *Simple merging on value from one dataset to another;

   %formatomatic(data=sashelp.classfit, start=name, to=predict, fmtname=$classpredict, type=C);
   data class_fit;
  	set sashelp.class;
  	predict = put(name,$CLASSPREDICT.);
   run;



   *Summarize and merge on data;

   proc means data=sashelp.class;
	  class age;
	  var height;
	  output out=class_ht mean=height_mean;
   run;
 
   %formatomatic(data=class_ht, start=age, to=height_mean, fmtname=htmean, type=N);

   data class_mean;
	  set sashelp.class;
	  ht_mean = put(age,htmean.);
   run;
 


   * Imagine this is a table in a relational database, and we want to use that to create a new category;

   data teenf;
	  agestart=11;
	  ageend=12;
	  cat='preteen';
	  output;
	  agestart=13;
	  ageend=16;
	  cat='teen';
	  output;
   run;

   %formatomatic(data=teenf, start=agestart, end=ageend, to=cat, fmtname=teenf, type=N);

   data class;
	  set sashelp.class;
	  teen = put(age,teenf.);
   run;


* Here we will use sashelp.cars. Our goal is to determine quartiles of MSRP and run a means on mpg_highway with the quartile as a class variable.;

proc means data=sashelp.cars noprint;
output out=quartiles min(msrp)=min q1(msrp)=q1 median(msrp)=q2 q3(msrp)=q3 max(msrp)=max;
run;

   data quartile_fmt;
	set quartiles;
		lowval=min;
		highval=q1;
		Quartile='MSRP in Bottom Quartile';
		output;

		lowval=q1;
		highval=q2;
		Quartile='MSRP in Second Quartile';
		output;

		lowval=q2;
		highval=q3;
		Quartile='MSRP in Third Quartile';
		output;

		lowval=q3;
		highval=max;
		Quartile='MSRP in Top Quartile';
		output;
   run;

   %formatomatic(data=quartile_fmt, start=lowval, end=highval, to=Quartile, library=work, fmtname=msrpquartf, type=N);

   * Avoid I/O step by using the format in proc means, otherwise you can merge the information on with a put statement
	in a data step eliminating a need for if/then or merging with 2 set statements;

   proc means data=sashelp.cars;
	class msrp;
	var mpg_highway;
	format msrp msrpquartf.;
   run;

   data cars;
	set sashelp.cars;
	msrp_quartile=put(msrp,msrpquartf.);
   run;



*/
