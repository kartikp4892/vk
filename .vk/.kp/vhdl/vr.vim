""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""  VHDL
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" highlight FIXME
mat WildMenu "FIXME"
mat Error "\*\*\* \zsFIXME\ze \*\*\*"

" <C-CR> Move forword in the next line
"inoremap <C-CR>   
"nnoremap <C-CR> o  

" <S-CR> Move backword in the next line
"inoremap <S-CR> <BS><BS>
"nnoremap <S-CR> o<BS><BS>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"change comment style ****************
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"map <F6> :%s/--+/---/e
"        \:g/-\{3}\zs=\+$/normal n$r-/e
"        \:%s/--\|\~\?/--/e
"        \:%s/--\s\{2,}/-- /e
"        \:g/--.\{}:\~/normal f:lx/e

" FIXME COMMENT

" library <M-V>
inoremap öl  ----------------------------------------------------------------------------------
            \-- Library and Package Declaration
            \----------------------------------------------------------------------------------
            \library IEEE;
            \use IEEE.std_logic_1164.all;
            \----------------------------------------------------------------------------------

" Entity <M-V>e
inoremap öe ^"ediwa
        \-------------------------------------------------------------------------------------
        \-- ENTITY      : 'e'
        \-------------------------------------------------------------------------------------
        \entity e is
        \  port(
        \  ma
        \);
        \end entity e;`a

" Architecture <M-V>a
inoremap öa ^"rdiwa
        \-------------------------------------------------------------------------------------
        \-- ARCHITECTURE : 'r'
        \-------------------------------------------------------------------------------------
        \architecture r of e is
        \  ma
        \begin  -- architecture r
        \  
        \end architecture r;`a

" Package <M-V>p
inoremap öp ^"pdiwa
        \-------------------------------------------------------------------------------------
        \-- PACKAGE     : 'p'
        \-------------------------------------------------------------------------------------
        \package p is
        \  ma
        \end package p;`a

" Package body <M-V><M-P>
inoremap öð ^"pdiwa
        \-------------------------------------------------------------------------------------
        \-- PACKAGE BODY : 'p'
        \-------------------------------------------------------------------------------------
        \package body p is
        \  ma
        \end package body p;`a

" Creat Component <M-V><M-C>
inoremap öã ^"ediwa
        \-------------------------------------------------------------------------------
        \-- COMPONENT   : 'e'
        \-------------------------------------------------------------------------------
        \component e is
        \  port(
        \  ma
        \);
        \end component e;`a

" creat instance of COMPONENT"
inoremap öic  <Left>"ediw
        \-------------------------------------------------------------------------------
        \-- INSTANCE    : 'e' COMPONENT
        \-------------------------------------------------------------------------------
        \U_e : component e
        \  port map (
        \  ma
        \);`a

" Copy Component from an entity <M-V><M-C>
" component copied in register \"v"
vnoremap öã  :s/\<\centity\>/component/ggv
        " \:g/: component/normal /componentgUiwgv"vyu

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" record : xxx <M-V>r
inoremap ör h"tdiwa
            \-----------------------------------------------------------------------------
            \-- RECORD      : 't'
            \-----------------------------------------------------------------------------
            \type t is record
            \  ma
            \end record t;`a

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Comment Block ---- <M-V>x
inoremap öx  -----------------------------------------------------------------------------
            \-- mz
            \-----------------------------------------------------------------------------`z

" Comment Block --** <M-V>c
inoremap öc  -------------------------------------------------------------------------------
            \-- mz
            \-------------------------------------------------------------------------------`z
            \Check and report that 

" M-V, M-X
inoremap öø  -- ==========================================================================
            \-- mz
            \-- ==========================================================================`z

" process <M-J>ps
inoremap êps <Left>"pdiw
            \-----------------------------------------------------------------------------
            \-- PROCESS     : 'p'
            \-----------------------------------------------------------------------------
            \p : process (ma)
            \begin -- p : process
            \end process p;`a

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" <M-~><M-~>
inoremap àà <End>--\|   

" <M-~><M-1>
"imap à± <End>--\|~  DESCRIPTION:~ 

" <M-~><M-1>
imap à± <End>-- DESCRIPTION: 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""convert comment style
"" <M-~><M-2>
"inoremap à² ma<Up>"ay$<Down>a`ar <End>r\|a--\|  
"
"" <M-~>2
"inoremap à2 ma<Up>"ay$<Down>a`ar <End>r\|a

"" include + at the end of the begining and ending lines boxed comment<M-~>`
"nmap à`  :g/+[=-]\{5,}$/normal $r+
"        \:g/\s*\zs--\|\ze[^\|]*$/normal $aà2

" include = at the end of the begining and ending lines boxed comment having + at the end<M-~><M-~>
"nmap àà  :%s/\s\+$//ge
"        \:g/[=-]\{5,}+$/normal $xxpp
"        \:g/\s*\zs--\|\ze.*\|$/normal $x
"        \:%s/\s\+$//ge
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
"""" <M-G><= 
"""inoremap ç<= <Tab><= 
""" <M-G><M-<>
""inoremap ç¬ <Tab><Tab><Tab><Tab>k^f<jDa<= 
""
"""" <M-G><M->>
"""inoremap ç=> <Tab>=> 
""" <M-G><M->>
""inoremap ê® <Tab><Tab><Tab><Tab>k^f=jDa=> 
""
"""" <M-G>:=
"""inoremap ç:= <Tab>:= 
""" <M-G><M-:>
""inoremap ê» <Tab><Tab><Tab><Tab>k^f:jDa:= 
""
"""" <M-G><M-:>
"""inoremap ç» <Tab>: 
""" <M-G>: (for :)
""inoremap ê: <Tab><Tab><Tab><Tab>k^f:jDa: 

"M-0
imap ° '0'
"M-1
imap ± '1'
"M-2
imap ² 'Z'
"M-3
imap ³ (others => 'ma')`a
"M-4
imap ´ (others => (others => 'ma'))`a

"<M-<>"
inoremap ¬ <space><= 

"<M->>"
inoremap ® <space>=> 

"<M-:>"
inoremap » <space>:= 

"<M-=>"
inoremap ½ <space>= 

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" mapping of brases (
"inoremap ( ()<Left>
"
"" mapping of '"'
"inoremap " ""<Left>
"
"" mapping of = to <space>=<space>
"inoremap = <space>=<space>
"
"" mapping of & to <space>&<space>
"inoremap & <space>&<space>
"
"" mapping of ; to ;<CR> "
"inoremap ; ;
"
"" mapping of ( \n ) <M-G>9
"inoremap ç9  (
"            \  ma
"            \<BS><BS>)`a
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Case <M-J>c
inoremap êc  case (ma) is
         \end case;`a

" when <M-J>w
inoremap êw <space>when 

" 'image() <M-J>i
inoremap êi 'image()<Left>

" after <M-J>af
inoremap êaf <space>after 

" severity <M-S>
inoremap ês severity 

" 'event <M-J>e
inoremap êe 'event 

" generic <M-J>g
inoremap êg  generic(
            \         ma
            \<BS><BS>);`a

" generic map <M-J>gm
inoremap êgm  generic map(
             \             ma
             \<BS><BS>);`a

" port map <M-J>pm
inoremap êpm   port map
              \  (
              \  ma
              \<BS><BS>);`a

" wait until <M-J>wu
inoremap êwu wait until (ma);`a

" wait for <M-J>wf
inoremap êwf wait for (ma);`a

" while loop <M-J>wl
inoremap êwl  while (ma) loop
             \end loop; --`a

""-----------------------------------------
" if - then <M-J>f
inoremap êf  if (ma) then
             \end if;`a

" elsif - then <M-J>ef
inoremap êef elsif (ma) then`a
""-----------------------------------------
""----------------------------------------
" array (0 to x) <M-J>ai
inoremap êar array (0 to x) of

" array (x downto 0) <M-J>ad
inoremap êad array (x downto 0) of
""----------------------------------------
"" (a downto b) <M-J>dt
"inoremap êdt (ma downto )`a
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" signal <M-G>s
inoremap çs signal 

" constant <M-G>c
inoremap çc constant 

" std_logic <M-G>l
inoremap çl std_logic 

""""""" std_logic_vector increment <M-G>lvd
""""""inoremap çlvd std_logic_vector(ma downto 0)`a
""""""
""""""" std_logic_vector decrement <M-G>lvd
""""""inoremap çlvu std_logic_vector(0 to )h

" std_logic_vector <M-G>lv"
inoremap çlv std_logic_vector 

" variable <M-G>v
inoremap çv variable 

" integer <M-G>i
inoremap çi integer 

" boolean <M-G>b
inoremap çb boolean 

" type <M-G>t
inoremap çt type ma is`a

" inout <M-G><M-I>
inoremap çé inout 

" procedure <M-G>pd
inoremap çpd  "pdiw
             \procedure p
             \  (
             \  ma
             \<BS><BS>);`a

" procedure body <M-G>pb
inoremap çpb  "pdiw
             \-----------------------------------------------------------------------------
             \-- PROCEDURE   : 'p'
             \-----------------------------------------------------------------------------
             \procedure p
             \  (
             \  ma
             \<BS><BS>)
             \<BS><BS>is
             \begin -- procedure p
             \end procedure p;`a

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" <M-I>
imap é in    
" <M-O>
imap ï out   
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" To write a comment after "end if" to LABLE the if condition" 
"imap àf ma^"ay$:.,/end if;/g/end if/normal $a p`aa
"nmap àf ma^"ay$:.,/end if;/g/end if/normal $a p`a

" To write a comment after "end loop" to LABLE the if condition" 
imap àw ma^"ay$:.,/end loop;/g/end loop;/normal $a p`aa
nmap àw ma^"ay$:.,/end loop;/g/end loop;/normal $a p`a
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"function to send report in dist_fpga RR

imap òò <Space><BS>
        \maHmb`a
        \:let a = @/
        \?:\s*processb"ayiw`bzt`aa
        \if (ms) then
        \  v_status := true;
        \else
          \v_status := false;
          \v_err_cnt:= v_err_cnt + 1;
        \end if; --
        \
        \v_run_cnt := v_run_cnt + 1;
        \REPORT_RESULT(TB_FILE_NAME     => "%",
        \              TB_PROCESS_NAME  => "a",
                      \DESCRIPTION      => "To check whether ",
                      \RUN_COUNT        => v_run_cnt,
                      \ERROR_COUNT      => v_err_cnt,
                      \EXPECTED         => ,
                      \ACTUAL           => ,
                      \STATUS           => v_status);`s

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"report formate for process
imap çò  -------------------------------------------------------------------------------
        \report cr & cr &       
        \"   FILE NAME    : %" & cr &
        \"   PROCESS NAME : 
        \:let a = @/
        \maHmb`a
        \?:\s*processb"ayiw`bzt`a
        \:let @/ = a
        \aa" & cr &
        \"   DESCRIPTION  : ma";
        \<BS><BS><BS><BS><BS><BS><BS>
        \-------------------------------------------------------------------------------`a

"report formate for procedure
imap çr  -------------------------------------------------------------------------------
        \report cr & cr &       
        \"   FILE NAME      : %" & cr &
        \"   PROCEDURE NAME : 
        \:let a = @/
        \maHmb`a
        \?^\s*procedure\s\+?el"ayiw`bzt`a
        \:let @/ = a
        \aa" & cr &
        \"   DESCRIPTION    : ma";
        \<BS><BS><BS><BS><BS><BS><BS>
        \-------------------------------------------------------------------------------`a

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" report result replace filename(line) with new one
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""map òep :let @a = @% . '(' . line(".") . ')'
"""        \ci"a
map òep :let @a = expand("%:t")
        \ci"a

function! Report_res()
  let @s = @/
  g/^\s*REPORT_RESULT(TB_FILE_NAME\s\+=>\s\+"\zs.*\ze"/normal nòep/e
  g/^\s\+"   FILE NAME\s\+:\s\+\zs.*\ze"\s\+&\s\+cr\s\+&/normal nòepF"a   FILE NAME    : /e
  let @d = expand("%:t")
  g/--\s*TEST BENCH FILENAME :/normal f:llc$d
  let @/ = @s
endfunction

nmap <M-F3> :silent! call Report_res()
nmap <silent> <S-F3> <M-F3>:w:n<S-F3>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap çr :g/report\s\+"\(\zs.*\ze\)";/normal nf"h"vd^Daçòv
