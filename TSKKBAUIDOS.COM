      �  �+ CyberYoshi64      CyberYoshi64      2 2                 exec"prg3:xcmd.lib"
XSCREEN 1
IF!ISOPAQUE(FADE())THEN FADE #GRAY,10
DIM I,K$,IN$,UN$,AN$,TMP,SLOT,CX,CY,X,Y,DIR$,SDR$
VAR FS%[0],FSD$[0],FSN$[0],FSA%[0],FSF$[0],DIRLIST[0],MAN$[0]
VAR FSVER%,FSSIZE%,FSES%,FSNAME$
DIM HIS$[1],HIS=0
GCLS.BGCLR:SPCLR:COLOR 15,0CLS:BACKTRACE:SLOT=CHKCHR(0,0)-48CLS:BACKCOLOR.
FONTDEF:FNT"FNT"

FSINIT
PUSH FSA%,11PUSH FSD$,"/Z:"PUSH FSN$,"TXT"PUSH FSF$,""
PUSH FSA%,11PUSH FSD$,"/Z:"PUSH FSN$,"DAT"PUSH FSF$,""
FSINIT2

GPAGE 2,2GCLS:FADE 0,10
PRNT 0,0,"%C0:FFC000%B%L"+FORMAT$("%02D",CX)+","+FORMAT$("%02D",CY)+"Welcome to %Bサカキバラ%BUI's DOS mode%B%E%C0:CCCCCCThis mode allows you to browse through the file%Esystem of サカキバラUI like in good old MS-DOS%Efashion!%E%E"
PRNT 0,0,"%C0:CCCCCC"
PRNTGETPOS OUT CX,CY
PRNT 0,0,"%C0:CCCCCC%C0:@@@@@@"
WHILE 1
HIS$[HIS]=IN$+""
IF BUTTON(1)==1 THEN HIS=MIN(LEN(HIS$)-1,MAX(HIS+1,0))PRNT 0,0,"%L"+FORMAT$("%02D",CX)+","+FORMAT$("%02D",CY)+SDR$+">"+" "*LEN(IN$)+" "IN$=HIS$[HIS]+""
IF BUTTON(1)==2 THEN HIS=MIN(LEN(HIS$)-1,MAX(HIS-1,0))PRNT 0,0,"%L"+FORMAT$("%02D",CX)+","+FORMAT$("%02D",CY)+SDR$+">"+" "*LEN(IN$)+" "IN$=HIS$[HIS]+""
K$=INKEY()
PRNT 0,0,"%L"+FORMAT$("%02D",CX)+","+FORMAT$("%02D",CY)+SDR$+">"+IN$+"_ "[(MAINCNT MOD 30)<15]+" "
PRNTGETPOS OUT X,Y
WHILE Y>23||CY>23-FLOOR((LEN(IN$)+3+LEN(SDR$))/50)DEC CY:DEC Y:WEND
IF K$!=""THEN COLOR 15,.CLS
IF K$<" "THEN
IF K$==CHR$(8)&&LEN(IN$)THEN _EAT POP(IN$)

ELSEIF K$=="%"THEN
COLOR 3,1LOCATE 0,28PRINT "% cannot be written!"COLOR 15,.

ELSEIF LEN(IN$)<127THEN
INC IN$,K$

ENDIF
IF K$==CHR$(13)THEN INTERPRET
VSYNC
WEND
@END
 END
DEF INTERPRET
IN$=TRIM$(IN$)
AN$=IN$+""
WHILE INSTR(IN$,"%%")>-1IN$[INSTR(IN$,"%%")]=""WEND
UN$=UCAPS$(IN$)
IF IN$!=""THEN
TMP$=SHIFT(HIS$)
UNSHIFT HIS$,IN$
UNSHIFT HIS$,""
ENDIF
IF LEN(HIS$)>20 THEN _EAT POP(HIS$)
PRNT 0,0,"%L"+FORMAT$("%02D",CX)+","+FORMAT$("%02D",CY)+SDR$+">"+AN$+"  %E"
INC CY,2+FLOOR((LEN(IN$)+2+LEN(SDR$))/50)

IF FS_FIND(FSD$,FSN$,DIR$+"/"+IN$)!=-1THEN
TMP0=FS_FIND(FSD$,FSN$,DIR$+"/"+IN$)

IF RIGHT$(UN$,4)==".CFD"THEN
FONTDEF:FNT LEFT$(UN$,LASTINSTR(UN$,"."))

ELSEIF (FSA%[TMP0]AND 2)THEN
 PRNT 0,1,"%EThis is a folder and can't be run.%ETry CD on it.%E"

ELSE
 PRNT 0,1,"%E%BOops%B... Looks like there's no code handling this%Efile.%E"

ENDIF

ELSEIF UN$=="ABOUT"THEN
MAN$=EMPTY1$()
PUSH MAN$,"%B%C0:FFC040%C1:806020About the file system%C0!%C1!%B"
PUSH MAN$,""
PUSH MAN$,"It's unlike Windows but more like Linux."
PUSH MAN$,""
PUSH MAN$,"File and folder names are case-sensitive."
PUSH MAN$,"The commands aren't. They don't care about it."
PUSH MAN$,""
PUSH MAN$,"Like Windows, the root is the “drive”. It's"
PUSH MAN$,"in quotes since the FS is just a big file."
PUSH MAN$,""
PUSH MAN$,"The C: “drive” contains the folders and files"
PUSH MAN$,"described in the FS."
PUSH MAN$,""
PUSH MAN$,"The Z: “drive” contains the project's files in"
PUSH MAN$,"a simple TXT and DAT folder structure."
PUSH MAN$,""
FOR I=0TO LEN(MAN$)-1
IF I&&!(I MOD 20)THEN
PRNT 0,1,"%EPress a button to continue."
WHILE BUTTON()WEND:WAIT 15
WHILE!BUTTON(3)WEND
ENDIF
PRNT 0,1,MAN$[I]
NEXT

ELSEIF UN$=="EXIT"THEN
 GOTO STR$(SLOT)+":@END

ELSEIF UN$=="CLS"THEN
 PRNT 0,0,"%X"CLS

ELSEIF UN$=="HELP"THEN
 PRNT 0,1,"%E%BHELP%B - Lists available commands%E%E%BAvailable commands:%B%E%BHELP%B - Show this help%E%BEXIT%B - Return from DOS mode%E%E%BNeed more help?%B Contact サイバーヨッシー64!%EYou can find it in %UMANUAL%U!"

ELSEIF LEFT$(UN$,3)=="DIR"THEN
IF INSTR(UN$,"/?")>-1THEN
 PRNT 0,1,"%E%BDIR%B - Lists directory contents%E%E%B/?%B - Show this help%E"

ELSEIF LEN(UN$)!=3THEN
 BEEP 2,-350
 PRNT 0,0,"%C0:FF0000%C1:400000%Bdir: Doesn't take arguments.%C0!%C1!%B%E" 
 
ELSE
DIRLIST=EMPTY1%()
FOR I=0TO LEN(FSN$)-1
IF FINDAT(I,FSD$,DIR$)!=-1THEN
I=FINDAT(I,FSD$,DIR$)
PUSH DIRLIST,I
ELSE
BREAK
ENDIF
NEXT
FOR I=0TO LEN(DIRLIST)-1
IF I&&!(I MOD 20)THEN
PRNT 0,1,"%EPress a button to continue."
WHILE BUTTON()WEND:WAIT 15
WHILE!BUTTON(3)WEND
ENDIF
PRNT 0,1,FORMAT$("% -32S %08X",LEFT$(FSN$[DIRLIST[I]],32-(LEN(FSN$[DIRLIST[I]])>32))+"…"*(LEN(FSN$[DIRLIST[I]])>32),FSA%[DIRLIST[I]])
NEXT
ENDIF

ELSEIF LEFT$(UN$,2)=="CD"THEN

IF INSTR(UN$,"/?")>-1THEN
PRNT 0,0,"%E%BCD%B - %BC%Bhange %BD%Birectory%E%Ecd .. - Go up the folder hierachy%Ecd [dir name] - Enter folder%E%E"

ELSEIF RIGHT$(UN$,2)==".."THEN
IF LEN(DIR$)&&LASTINSTR(DIR$,"/")!=-1 THEN
DIR$=LEFT$(DIR$,LASTINSTR(DIR$,"/"))

ELSE
BEEP 2,-250
PRNT 0,0,"%C0:FF0000%C1:400000%BCannot go out futher!%C0!%C1!%B%E"

ENDIF

ELSEIF UN$=="CD"THEN
BEEP 2,-250
PRNT 0,0,"%C0:FF0000%C1:400000%Bcd: Missing argument(s). Expected 1 argument%C0!%C1!%B%E" 

ELSEIF INSTR(IN$,"/")>-1||INSTR(IN$,"")>-1||INSTR(IN$,"%")>-1THEN
BEEP 2,-350
PRNT 0,0,"%C0:FF0000%C1:400000%Bcd: Argument cannot contain “/”, “” or “%%”.%C0!%C1!%B%E" 

ELSEIF FS_FIND(FSD$,FSN$,DIR$+"/"+MID$(IN$,3,128))!=-1THEN
INC DIR$,"/"+MID$(IN$,3,128)

ENDIF

ELSEIF IN$==""THEN

ELSE
TMP=INSTR(IN$," ")

IF TMP==-1THEN
TMP$=AN$+""
ELSE
TMP$=LEFT$(AN$,TMP)
ENDIF

BEEP 2,-500
PRNT &HFF400000,0,"%C0:FF0000%C1:400000%Bsh: “"+TMP$+"” not found.%C0!%C1!%B%E"

ENDIF

SDR$="…"*(LEN(DIR$)>20)+RIGHT$(DIR$,20)
IN$=""HIS=0
PRNTGETPOS OUT CX,CY
END
DEF FSINIT
DIM TMP%[6]
 IF!CHKFILE("DAT:@SKKBAUI.CYFS")THEN RETURN
 LOAD"DAT:@SKKBAUI.CYFS",FS%,0
 FSVER%=FS%[2]FSSIZE%=FS%[3]FSES%=FS%[4]
 TMP%[0]=0
 TMP%[4]=21
 FOR I=5TO 20
  INC FSNAME$,CharFromUint32$(FS%[I],0,0)
 NEXT
 IF FSVER%!=1048576THEN RETURN
 IF FSSIZE%!=LEN(FS%)THEN RETURN
 IF FSES%<4THEN RETURN

 WHILE TMP%[0]<FSES%
 PUSH FSA%,FS%[TMP%[4]]
 INC TMP%[4]
 TMP%[5]=FS%[TMP%[4]]+TMP%[4]
 FOR I=TMP%[4]+1 TO TMP%[5]
  INC _$,CharFromUint32$(FS%[I],0,0)
 NEXT
 PUSH FSD$,_$+""
 TMP%[4]=I+._$=""
 TMP%[5]=FS%[TMP%[4]]+TMP%[4]
 FOR I=TMP%[4]+1 TO TMP%[5]
  INC _$,CharFromUint32$(FS%[I],0,0)
 NEXT
 PUSH FSF$,_$+""
 TMP%[4]=I+._$=""
 TMP%[5]=FS%[TMP%[4]]+TMP%[4]
 FOR I=TMP%[4]+1 TO TMP%[5]
  INC _$,CharFromUint32$(FS%[I],0,0)
 NEXT
 PUSH FSN$,_$+""
 TMP%[4]=I+._$=""
 INC TMP%[0]
 WEND
END
DEF FSINIT2
VAR I=0,TMP%[0],F$[0]FILES F$
 WHILE I<LEN(F$)
  PUSH FSA%,13-(F$[I][1]=="@")
  PUSH FSD$,"/Z:/"+MID$("TXTDAT",(F$[I][0]==" ")*3,3)
  PUSH FSN$,MID$(F$[I],1,14)
  PUSH FSF$,MID$("TXTDAT",(F$[I][0]==" ")*3,3)+":"+MID$(F$[I],1,14)
  INC I
 WEND
 SORT FSN$,FSA%,FSD$,FSF$
 SORT FSA%,FSN$,FSD$,FSF$
END

~^�����s��$�6