:Namespace DyalogBuild ⍝ V 1.11
⍝ This code is experimental and being used internally by the Dyalog Tools group.
⍝ Feedback to tools@dyalog.com is very welcome!
⍝
⍝ 2017 04 11 MKrom: initial code
⍝ 2017 05 09 Adam: included in 16.0, upgrade to code standards
⍝ 2017 05 21 MKrom: lowercase Because and Check to prevent breaking exisitng code
⍝ 2017 05 22 Adam: reformat
⍝ 2017 05 23 Adam: uppercased Because and Check and moved Words, reinstate blank lines, make compatible with 15.0
⍝ 2017 06 05 Adam: typo
⍝ 2017 06 15 Adam: TOOLS → EXPERIMENTAL
⍝ 2017 06 18 MKrom: test for missing argument
⍝ 2017 06 23 MKrom: get rid of empty fn names
⍝ 2017 06 24 Brian: Allow commented lines in dyalogtest files, drop leading comma in args.tests, exit gracefully if no tests defined
⍝ 2017 06 27 Adam: Add disclaimer to help
⍝ 2017 07 24 MKrom: save exists state

    ⎕ML←1

    :Section ADOC

    ∇ t←Describe
      t←1↓∊(⎕UCS 10),¨{⍵/⍨∧\(⊂'')≢¨⍵}Comments ⎕SRC ⎕THIS ⍝ first block of non-empty comment lines
    ∇

    ∇ (n v d)←Version;f;s
      s←⎕SRC ⎕THIS
      f←Words⊃s                     ⍝ split first line
      n←2⊃f                         ⍝ ns name
      v←'.0',⍨'V'~⍨⊃⌽f              ⍝ version number
      d←1↓∊'-',¨3↑Words⊃⌽Comments s ⍝ date
    ∇

    Words←' '∘≠{⎕ML←3 ⋄ ⍺⊂⍵}⊢
    Comments←{1↓¨⍵/⍨∧\'⍝'=⊃∘{(∨\' '≠⍵)/⍵}¨⍵}1∘↓
    :EndSection ───────────────────────────────────────────────────────────────────────────────────

    :Section UTILS

    eis←{1=≡⍵:⊂⍵ ⋄ ⍵}                           ⍝ enclose if simple
    Split←{dlb¨1↓¨⍺(=⊂⊢)⍺,⍵}                    ⍝ Split ⍵ on ⍺, and remove leading blanks from each segment
    GetParam←{⍺←'' ⋄ (⌊/names⍳eis ⍵)⊃values,⊂⍺} ⍝ Get value of parameter
    GetNumParam←{⍺←⊣ ⋄ ⊃2⊃⎕VFI ⍺ GetParam ⍵}    ⍝ Get numeric parameter (0 if not set)
    dlb←{(∨\' '≠⍵)/⍵}                           ⍝ delete leading blanks
    lc←819⌶                                     ⍝ lower case
    uc←1∘(819⌶)                                 ⍝ upper case
    null←0                                      ⍝ UCMD switch not specified

    ∇ w←WIN ⍝ running under Windows
      :Trap 6
          w←⎕SE.SALTUtils.WIN ⍝ ≥16.0
      :Else
          w←'Win'≡3↑⊃'.'⎕WG'APLVersion' ⍝ ≤15.0
      :EndTrap
    ∇

    ∇ r←∆CSV args;z;file;encoding;coltypes;num
    ⍝ Primitive ⎕CSV for pre-v16
    ⍝ No validation, no options
     
      :Trap 2 ⍝ Syntax Error if ⎕CSV not available
          r←⎕CSV args
      :Else
          (file encoding coltypes)←args
          z←1⊃⎕NGET file 1
          z←1↓¨↑{(','=⍵)⊂⍵}¨',',¨z
          :If 0≠⍴num←(2=coltypes)/⍳⍴coltypes
              z[;num]←{⊃2⊃⎕VFI ⍵}¨z[;num]
          :EndIf
          r←z
      :EndTrap
    ∇

    :EndSection ────────────────────────────────────────────────────────────────────────────────────

    :Section TEST "DSL" FUNCTIONS

    ∇ r←Test args;⎕TRAP;start;source;ns;files;f;z;fns;filter;verbose;LOGS;steps;setups;setup;DYALOG;WSFOLDER;suite;halt;m;v;sargs;ignored;type;TESTSOURCE;extension;repeat;run;quiet;setupok;trace
      ⍝ run some tests from a namespace or a folder
      ⍝ switches: args.(filter setup teardown verbose)
     
      ⍝ Not used here, but are for test scripts that need to locate data:
      DYALOG←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
      WSFOLDER←⊃⎕NPARTS ⎕WSID
     
      LOGS←''
      (verbose filter halt quiet trace)←args.(verbose filter halt quiet trace)
      :If null≢repeat←args.repeat
          repeat←⊃2⊃⎕VFI repeat
      :EndIf
     
      :If halt ⋄ ⎕TRAP←0 'S' ⋄ :EndIf ⍝ Defeat UCMD trapping
     
      repeat←1⌈repeat
     
      :If 0=⍴args.Arguments  
      :AndIf 9≠#.⎕NC source←⊃args.Arguments←,⊂'Tests'
          r←'An argument is required - see ]?dtest for more information.' ⋄ →0
      :ElseIf 9=#.⎕NC source←1⊃args.Arguments ⍝ It's a namespace
          ns←#⍎source
          TESTSOURCE←⊃1 ⎕NPARTS''
      :Else                               ⍝ Not a namespace
          :If ⎕NEXISTS f←source           ⍝ Argument is a file
          :OrIf ⎕NEXISTS f←source,'.dyalogtest'
              (TESTSOURCE z extension)←⎕NPARTS f
              :If 2=type←⊃1 ⎕NINFO f
                  :If '.dyalogtest'≡lc extension ⍝ That's a suite
                      :If null≡args.suite
                          args.suite←f
                      :EndIf
                      f←¯1↓TESTSOURCE ⋄ type←1 ⍝ Load contents of folder
                  :Else                          ⍝ Arg is a source file - load it
                      ⍝ ns←#.⎕FIX 'file://',f    ⍝ When the interpreter can do it one day
                      ⎕SE.SALT.Load f,' -target=ns'
                      :If verbose ⋄ 0 Log'load file ',source ⋄ :EndIf
                  :EndIf
              :EndIf
     
              :If 1=type
                  files←⊃0(⎕NINFO⍠1)f,'/*.dyalog'
                  ns←⎕NS''
                  :For f :In files
                  ⍝ z←ns.⎕FIX 'file://',f ⍝ /// source updates not working
                      ⎕SE.SALT.Load f,' -target=ns'
                  :EndFor
                  :If verbose ⋄ 0 Log(⍕≢files),' files loaded from ',source ⋄ :EndIf
              :EndIf
          :Else
              LogTest'"',source,'" is neither a namespace or a folder.'
              →FAIL⊣r←LOGS
          :EndIf
      :EndIf
     
      :If null≢suite←args.suite ⍝ Is a test suite defined?
          ⍝ Merge settings
          ignored←⍬
          sargs←LoadTestSuite suite
     
          :For v :In (sargs.⎕NL-2)∩args.⎕NL-2 ⍝ overlap?
              :If null≢args⍎v
                  ignored,←⊂v
              :EndIf
          :EndFor
          'args'⎕NS sargs ⍝ merge
          :If 0≠≢ignored
              0 Log'*** warning - modifiers overwritten by test suite contents: ',,⍕ignored
          :EndIf
      :EndIf
     
    ⍝ Establish test DSL in the namespace
      :If halt=0 ⋄ ns.Check←≢
      :Else
          'ns'⎕NS'Check'
      :EndIf
      'ns'⎕NS'Because'
      ns.Log←{⍺←⊢ ⋄ ⍺ ##.LogTest ⍵}
     
      :If args.tests≢0
          fns←(','Split args.tests)~⊂''
          :If ∨/m←3≠⌊ns.⎕NC fns
              0 Log'*** function(s) not found: ',,⍕m/fns
              fns←(~m)/fns
          :EndIf
      :Else ⍝ No functions selected - run all named test_*
          fns←↓{⍵⌿⍨'test_'∧.=⍨5(↑⍤1)⍵}ns.⎕NL 3
      :EndIf
     
      :If null≢filter
      :AndIf 0=≢fns←(1∊¨filter∘⍷¨fns)/fns
          0 Log'*** no functions match filter "',filter,'"'
          →FAIL⊣r←LOGS
      :EndIf
     
      :If null≢setups←args.setup 
          setups←' 'Split args.setup
      :EndIf
      r←LOGS
     
      :For run :In ⍳repeat
          :If verbose∧repeat≠0
              0 Log'run #',(⍕run),' of ',⍕repeat
          :EndIf
          :For setup :In setups
              steps←0
              start←⎕AI[3]
              LOGS←''
              :If verbose∧1<≢setups ⋄ r,←⊂'For setup = ',setup ⋄ :EndIf
              :If ~setupok←null≡f←setup
                  :If 3=ns.⎕NC f ⍝ function is there
                      :If verbose ⋄ 0 Log'running setup: ',f ⋄ :EndIf
                      f LogTest z←(ns⍎f)⍬
                      setupok←0=≢z
                  :Else ⋄ LogTest'-setup function not found: ',f
                  :EndIf
              :EndIf
     
              →setupok↓END
     
              :If verbose
                  0 Log'running ',(⍕≢fns),' tests'↓⍨¯1×1=≢fns
              :EndIf
              :For f :In fns
                  steps+←1
                  :If verbose ⋄ 0 Log'running: ',f ⋄ :EndIf
                  (trace/1)ns.⎕STOP f
                  :Trap (halt∨trace)↓0
                     f LogTest (ns⍎f) ⍬                  
                  :Else
                     f LogTest ⊃⎕DM
                  :EndTrap
                  
              :EndFor
     
              :If null≢f←args.teardown
                  :If 3=ns.⎕NC f ⍝ function is there
                      :If verbose ⋄ 0 Log'running teardown: ',f ⋄ :EndIf
                      f LogTest(ns⍎f)⍬
                  :Else ⋄ LogTest'-teardown function not found: ',f
                  :EndIf
              :EndIf
     
     END:
              :If 0=⍴LOGS
                  r,←(quiet≡null)/⊂'   ',((1≠≢setups)/setup,': '),(⍕steps),' test',((1≠steps)/'s'),' passed in ',(1⍕0.001×⎕AI[3]-start),'s'
              :Else
                  r,←(⊂'Errors encountered',(setup≢null)/' with setup "',setup,'":'),'   '∘,¨LOGS
              :EndIf
          :EndFor ⍝ Setup
      :EndFor ⍝ repeat
     
     FAIL:
      r←⍪r
    ∇

    ∇ r←expect Check got
      :If r←expect≢got
          ⎕←'expect≢got:'
          ⎕←(2⊃⎕SI),'[',(⍕2⊃⎕LC),'] ',(1+2⊃⎕LC)⊃(1⊃⎕RSI).⎕NR 2⊃⎕SI
          :If ##.halt ⋄ ∘∘∘ ⋄ :EndIf
      :EndIf
    ∇

    ∇ line←line Because msg
     ⍝ set global "r", return branch label
      r←(2⊃⎕SI),'[',(⍕2⊃⎕LC),']: ',msg
    ∇

    ∇ args←LoadTestSuite suite;setups;lines;i;cmd;params;names;values;tmp;f
     
      args←⎕NS''
     
      :If ⎕NEXISTS suite
          lines←⊃⎕NGET suite 1
      :Else
          r←,⊂'Test suite "',suite,'" not found.' ⋄ →0
      :EndIf
     
      args.tests←⍬
     
      :For i :In ⍳≢lines
          :If ':'∊i⊃lines ⍝ Ignore blank lines
          :AndIf '⍝'≠1↑i⊃lines
              (cmd params)←':'Split i⊃lines
              (names values)←↓[1]↑¯2↑¨(⊂⊂''),¨'='Split¨','Split params
              cmd←lc cmd~' ' ⋄ names←lc names
     
              :If (i=1)∧'dyalogtest'≢cmd
                  'First line of file must define DyalogTest version'⎕SIGNAL 11
              :EndIf
     
              :Select cmd
              :Case 'dyalogtest'
                  :If 0.1=_version←GetNumParam'version' ''
                      :If verbose
                          0 Log'DyalogTest version ',⍕_version
                          Log'Processing Test Suite "',suite,'"'
                      :EndIf
                  :Else
                      'This version of ]',Cmd,' only supports Dyalog Test file format v0.1'⎕SIGNAL 2
                  :EndIf
     
              :Case 'setup'
                  args.setup←GetParam'fn' ''
                  args.setup←{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',args.setup,' '
     
              :Case 'test'
                  :If 0=⎕NC'args.tests' ⋄ args.tests←⍬ ⋄ :EndIf
                  args.tests,←',',GetParam'fn' ''
     
              :Case 'teardown'
                  args.teardown←GetParam'fn' '' ⍝ function is there
     
              :CaseList 'id' 'description'
                  :If verbose ⋄ Log cmd,': ',GetParam'' ⋄ :EndIf
              :Else
                  Log'Invalid keyword: ',cmd
              :EndSelect
          :EndIf
      :EndFor
     
      args.tests↓⍨←1  ⍝ drop off leading comma
    ∇

    :EndSection ────────────────────────────────────────────────────────────────────────────────────

    :Section BUILD

    ∇ r←Build args;file;prod;path;lines;extn;name;exists;extension;i;cmd;params;values;names;_description;_id;_version;id;v;target;source;wild;options;z;tmp;types;start;_defaults;f;files;n;quiet;save;ts
    ⍝ Process a .dyalogbuild file
     
      start←⎕AI[3]
      extension←'.dyalogbuild' ⍝ default extension
     
      i←0 ⍝ we are on "line zero" if any logging happens
     
      file←1⊃args.Arguments
      (prod quiet save)←args.(production quiet 0) ⍝ save must be 0, ⎕SAVE does not work from a UCMD
      Clear args.clear
     
      (exists file)←OpenFile file
      (path name extn)←⎕NPARTS file
     
      ('File not found: ',file)⎕SIGNAL exists↓22
     
      lines←1⊃⎕NGET file 1
     
      _version←0
      _id←''
      _description←''
      _defaults←'⎕ML←⎕IO←1'
     
      :For i :In ⍳≢lines
          :If ~':'∊i⊃lines ⋄ :Continue ⋄ :EndIf ⍝ Ignore blank lines
          (cmd params)←':'Split i⊃lines
          (names values)←↓[1]↑¯2↑¨(⊂⊂''),¨'='Split¨','Split params
          cmd←lc cmd~' ' ⋄ names←lc names
     
          :If (i=1)∧'dyalogbuild'≢cmd
              'First line of file must define DyalogBuild version'⎕SIGNAL 11
          :EndIf
     
          :Select cmd
          :Case 'dyalogbuild'
              :If 0.1=_version←GetNumParam'version' ''
                  0 Log'DyalogBuild version ',⍕_version
                  Log'Processing "',file,'"'
              :Else
                  'This version of ]build only supports Dyalog Build file format v0.1'⎕SIGNAL 2
              :EndIf
     
          :Case 'id'
              id←GetParam'id' ''
              v←GetNumParam'version'
              Log'Building ',id,(v≠0)/' version ',⍕v
     
          :Case 'description'
              ⍝ no action
     
          :Case 'copy'
              wild←'*'∊source←GetParam'file' ''
              target←GetParam'target'
     
              :If ⎕NEXISTS path,target
                  :For f :In files←⊃0(⎕NINFO⍠1)path,target,'/*'
                      ⎕NDELETE f
                  :EndFor
              :Else
                  2 ⎕MKDIR path,target ⍝ /// needs error trapping
              :EndIf
     
              :If 0=≢files←⊃0(⎕NINFO⍠1)path,source
                  LogError'No files found to copy in ":',path,source,'"'
              :Else
                  :For f :In files
                      cmd←((1+WIN)⊃'cp' 'copy'),' "',f,'" "',path,target,'/"'
                      ((WIN∧cmd∊'/')/cmd)←'\'
                      {}⎕CMD cmd
                  :EndFor
              :EndIf
              :If (n←≢files)≠tmp←≢⊃0(⎕NINFO⍠1)path,target,'/*'
                  LogError(⍕n),' expected, but ',(⍕tmp),' files ended up in "',target,'"'
              :Else
                  Log(⍕n),' file',((n≠1)/'s'),' copied from "',source,'" to "',target,'"'
              :EndIf
     
          :Case 'run'
              LogError'run is under development'
              :Continue
     
              tmp←GetParam'file' ''
              (exists tmp)←OpenFile tmp
              :If ~exists ⋄ LogError'unable to find file ',tmp ⋄ :Continue ⋄ :EndIf
     
          :CaseList 'ns' 'class' 'csv'
              target←'#'GetParam'target'
              target←(('#'≠⊃target)/'#.'),target
              :If 0=≢source←GetParam'source' ''
                  'Source is required'Signal 11
              :EndIf
     
              :If (cmd≡'ns')∧0=⎕NC target
                  target ⎕NS''
                  :Trap 0
                      target⍎_defaults
                       ⍝ Log'Created namespace ',target
                  :Else
                      LogError'Error establishing defaults in namespace ',target,': ',⊃⎕DMX.DM
                  :EndTrap
              :EndIf
     
              :If cmd≡'csv'
                  types←2⊃⎕VFI GetParam'coltypes'
                  :If ~0=tmp←#.⎕NC target
                      LogError'Not a free variable name: ',target,', current name class = ',⍕tmp ⋄ :Continue
                  :EndIf
                  :Trap 999
                      tmp←∆CSV(path,source)'',(0≠≢types)/⊂types
                      ⍎target,'←tmp'
                      Log target,' defined from CSV file "',source,'"'
                  :Else
                      LogError⊃⎕DMX.DM
                  :EndTrap
                  :Continue
              :EndIf
     
              wild←'*'∊source
              options←(wild/' -protect'),prod/' -nolink'
     
              :Trap 0
                  z←⎕SE.SALT.Load tmp←path,source,((0≠≢target)/' -target=',target),options
              :Else
                  LogError⊃⎕DMX.DM
                  :Continue
              :EndTrap
     
              :If 0=≢z     ⍝ no names
                  LogError'Nothing found: ',tmp
              :ElseIf 1=≢z ⍝ exactly one name
                  Log{(uc 1↑⍵),1↓⍵}cmd,' ',source,' loaded as ',⍕z
              :Else        ⍝ many names
                  Log(⍕≢z),' names loaded from ',source,' into ',target
              :EndIf
     
          :CaseList 'lx' 'exec' 'defaults'
              :If 0=≢tmp←GetParam'expression' ''
                  LogError'expression missing'
              :Else
                  :If cmd≡'lx'
                      #.⎕LX←tmp
                      Log'Latent Expression set'
                  :Else ⍝ exec or defaults
                      :Trap 0 ⋄ #⍎tmp
                      :Else
                          LogError⊃⎕DMX.DM
                      :EndTrap
                      :If cmd≡'defaults' ⋄ _defaults←tmp ⋄ :EndIf ⍝ Store for use each time a NS is created
                  :EndIf
              :EndIf
     
          :Case 'target'
              :If 0=≢tmp←GetParam'wsid' ''
                  LogError'wsid missing'
              :Else
                  ⎕WSID←∊1 ⎕NPARTS path,tmp
                  Log'WSID set to ',⎕WSID
              :EndIf
     
          :Else
              LogError'Invalid keyword: ',cmd
          :EndSelect
     
      :EndFor
      :If prod ⋄ ⎕EX'#.SALT_Var_Data' ⋄ :EndIf
     
      :If save≢0 ⍝ This doesn't work at the moment
          :If save≡1 ⋄ save←⎕WSID ⋄ :EndIf
          ts←{0::0 ⋄ ⊃3 ⎕NINFO ⍵}save
          0 ⎕SAVE save
      :EndIf
     
      :If quiet ⋄ r←0 0⍴0
      :Else ⋄ r←'DyalogBuild: ',(⍕≢lines),' lines processed in ',(1⍕0.001×⎕AI[3]-start),' seconds.'
      :EndIf
    ∇

    ∇ (exists file)←OpenFile file;tmp;path;extn;name
      (path name extn)←⎕NPARTS file
      :If exists←⎕NEXISTS file
          :If 1=⊃1 ⎕NINFO file ⍝ but it is a folder!
          :AndIf exists←⎕NEXISTS tmp←file,'/',name,extension ⍝ If folder contains name.dyalogbuild
              file←tmp ⍝ Then use the file instead
          :EndIf
      :Else
          exists←⎕NEXISTS file←file,(0=⍴extn)/extension
      :EndIf
    ∇

    ∇ Clear clear;tmp;n
      →(clear≡0)⍴0
      :If (clear≡1)∨0=≢clear ⋄ #.(⎕EX ⎕NL⍳9) ⋄ Log'workspace cleared'
      :ElseIf ∧/1⊃tmp←⎕VFI clear
          n←#.⎕NL 2⊃tmp
          #.⎕EX n ⋄ Log'Expunged ',(⍕≢n),' names of class ',clear
      :Else
          LogError'invalid argument to clear, should be empty or a numeric list of name classes to expunge'
      :EndIf
    ∇

    LineNo←{'[',(,'ZI3'⎕FMT ⍵),']'}

    ∇ {f}LogTest msg
      →(0=⍴msg)⍴0
      :If 2=⎕NC'f' ⋄ msg←(f,': ')∘,¨eis msg ⋄ :EndIf
      :If verbose ⋄ ⎕←msg ⋄ :EndIf
      LOGS,←eis msg
    ∇

    ∇ {pre}Log msg
      →quiet⍴0
      :If 0=⎕NC'pre' ⋄ :OrIf pre=1 ⋄ msg←' ',(LineNo i),' ',msg ⋄ :EndIf
      ⎕←msg
    ∇

    ∇ dm Signal en
     ⍝ subroutine of Build: uses globals i and file
      (dm,' in line ',(LineNo i),' of file ',file)⎕SIGNAL 2
    ∇

    ∇ {r}←LogError msg
     ⍝ subroutine of Build: uses globals i and file
      ⎕←r←' ***** ',(LineNo i),' ',msg
    ∇

    :EndSection

    :Section UCMD

    ∇ r←List
      r←⎕NS¨2⍴⊂''
      r.Group←⊂'EXPERIMENTAL'
      r.Name←'DBuild' 'DTest'
      r.Desc←'Execute a DyalogBuild file' 'Run tests from a namespace or folder'
      r.Parse←'1S -production -quiet -clear[=]' '1S -tests= -filter= -setup= -teardown= -suite= -verbose -quiet -halt -trace -repeat='
    ∇

    ∇ Û←Run(Ûcmd Ûargs)
     ⍝ Run a build
      :Select Ûcmd
      :Case 'DBuild'
          Û←Build Ûargs
      :Case 'DTest'
          Û←Test Ûargs
      :EndSelect
    ∇

    ∇ r←level Help Cmd;d
      d←⊂'This user command is part of an experimental build/test framework used internally at Dyalog.'
      d,←'Contact apltools@dyalog.com for more information.' ''
      :Select Cmd
      :Case 'DBuild'
          r←⊂'Run one or more DyalogBuild scripts'
          r,←d
          r,←⊂']',Cmd,' files [-clear[=NCs]] [-production]'
          :If ×level
              r,←⊂''
              r,←⊂'files  name of one or more .dyalogbuild file(s)'
              r,←⊂''
              r,←⊂'-clear[=NCs]  expunge all objects, optionally of specified name classes only'
              r,←⊂'-production   remove links to source files'
              r,←⊂'-quiet        only output actual errors'
          :EndIf
     
      :Case 'DTest'
          r←⊂'Run a selection of functions named test_* from a namespace, file or folder'
          r,←d
          :If 0=level
              r,←⊂']',Cmd,' {ns|file|path} [-halt] [-filter=string] [-quiet] [-repeat=n] [-setup=fn] [-suite=file] [-teardown=fn] [-trace] [-verbose]'
          :Else
              r,←⊂']',Cmd,' {ns|file|path} [modifiers] '
              r,←⊂''
              r,←⊂'ns    namespace in the current workspace'
              r,←⊂'file  .dyalog file containing a namespace'
              r,←⊂'path  path to directory containing functions in .dyalog files'
              r,←⊂''
              r,←⊂'Optional modifiers are:'         
              r,←⊂'    -tests=         comma-separated list of tests to run'
              r,←⊂'    -halt           halt on error rather than log and continue'
              r,←⊂'    -filter=string  only run functions where string is found in the leading ⍝Test: comment'
              r,←⊂'    -quiet          qa mode: only output actual errors'
              r,←⊂'    -repeat=n       repeat test n times'
              r,←⊂'    -setup=fn       run the function fn before any tests'
              r,←⊂'    -suite=file     run tests defined by a .dyalogtest file'
              r,←⊂'    -teardown=fn    run the function fn after all tests'
              r,←⊂'    -trace          set stop on line 1 of each test function'
              r,←⊂'    -verbose        display more status messages while running'
          :EndIf
      :EndSelect
      :If 0=level
          r,←⊂']??',Cmd,' ⍝ for more info'
      :EndIf
    ∇

    :EndSection ────────────────────────────────────────────────────────────────────────────────────
:Endnamespace ⍝ DyalogBuild
