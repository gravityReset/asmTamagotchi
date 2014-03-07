include 'emu8086.inc' ;biblioteque de emu8086

org  100h     
     
     
     
     CURSOROFF
CALL affichageDem
CALL attentedunetouche  
CALL CLEAR_SCREEN
CALL affichagejeu
GOTOXYTama 45,10
CALL afficheTama
CALL afficheInfo

bouclePrinc:   ;boucle principale

CALL updateAge
CALL attentedunetouche
CMP AL,61h    ;si touche =a
JE lta
CMP AL,7Ah    ;si touche =z
JE ltz
CMP AL,65h    ;si touche =e
JE lte
CMP AL,72h    ;si touche =r
JE ltr
CMP AL,1Bh    ;si c'est echp
JE fin
JMP bouclePrinc
 lta:		   ;quand a est appuyé
   CALL snack
   
   JMP bouclePrinc
 ltz:          ;quand z est appuyé
   CALL meal
   
   JMP bouclePrinc ;fin de la boucle principale
 lte:
   CALL play
   
   JMP bouclePrinc
 ltr:         ;touche r appuyé
   CALL reprimand
     
   JMP bouclePrinc 
    
 

    fin:
    GOTOXY 35,15
    PRINT 'A bientot'
  RET
  
  ;fin du programme
  
  
  ;debut des fonctions
getAlea PROC  ;renvoie nbAlea a jour 
   nbAlea0:
	CMP nbAlea, 0
	JNE nextAlea ;si le nombre =0 on l'initialise avec le temps
	MOV AH,00h
	INT 1Ah
	MOV AX,DX
	MOV nbAlea,AX
  nextAlea:
	MOV AX,nbAlea
	MOV nb0,5
	MUL nb0       ;on multiplie nbAlea par 4
	MOV nb0,AX    ;qu'on stoque dans nb0
	MOV AX,nbAlea
	SUB nb1,AX
	MUL nb0
	MOV nbAlea, AX;soit la formule nbAlea=(nbAlea*5)(1-nbAlea)
	CMP nbAlea,0
	JE nbAlea0
	RET
 nb0 DW 0
 nb1 DW 1
 ENDP

  
play PROC
    
    
	CMP discipline ,4 ;si la discipline est faible
	JNL affichagePlay
	CMP discipline ,0
	JE neVeutPasJouer
	CALL getAlea
	CMP nbAlea,32768 ;une chance sur 2
	JA neVeutPasJouer 
	
  affichagePlay:
    GOTOXY 30,3
    PRINT 'q: left and s: right echp:quit gamemode'
    MOV reprimandJustified,0	
	jmp nextBclJeu
  boucleJeu:  
    CALL getAlea
    GOTOXYTama 45,10
    CALL afficheTama
   nextBclJeu:
    CALL getAlea
    CALL attentedunetouche
    CMP AL,71h    ;si touche =q gauche
    JE ltqJeu
    CMP AL,73h    ;si touche =s droite
    JE ltsJeu
    CMP AL,1Bh    ;si c'est echp
    JE finJeu  
    JMP nextBclJeu ;autre touche
  ltqJeu:
    CMP nbAlea,32768 ;une chance sur 2
	JA pashappyJeu
	GOTOXYTama 30,10
    CALL afficheTama
	JMP happyJeu
  ltsJeu:
    CMP nbAlea,32768 ;une chance sur 2
	JNA pashappyJeu
	GOTOXYTama 60,10
    CALL afficheTama
	JMP happyJeu
	
   pashappyJeu:
     GOTOXY 45,4
     PRINT 'rate!   '
      
	 CALL decHun
	 CALL afficheInfo
	 GOTOXY 45,4
	 PRINT '         '
     JMP boucleJeu
   happyJeu: 
     GOTOXY 45,4
     PRINT 'happy!!'
     
    CALL decHun
	CALL incHap
	CALL incHap
	CALL afficheInfo
	GOTOXY 45,4
	PRINT '         '
    JMP boucleJeu
    
  neVeutPasJouer:
	GOTOXY 30,3
	PRINT 'I dont want to play  Press a key        '
	MOV reprimandJustified,1
	CALL attentedunetouche
	
  finJeu:
    GOTOXY 30,3
	PRINT '                                        ' ;on clear le texte
	
    
  RET
ENDP

snack PROC;fonction snack
	GOTOXY 30,3
	PRINT 'It s snack time!'
	
	CMP discipline ,4
	JNL firstSnack
	CMP discipline,0
	JE neVeutPasManger
	CALL getAlea
	CMP nbAlea,32768
	JA neVeutPasManger
	

  firstSnack:
	CMP hapiness,10
	JE nextSnack
	CALL incHap    ;on augmente le bonheur de 1
	MOV reprimandJustified,0
	
  nextSnack:
    CMP hungriness,10
	JE attenteEntreSnack
	CALL incHun  ;on augmente le fait d'avoir plus fin
	MOV reprimandJustified,0 
	JMP attenteEntreSnack
	
  neVeutPasManger:
	GOTOXY 30,3
	PRINT 'RRRHHH, NO!!   '
	MOV reprimandJustified,1
	
  attenteEntreSnack:
    CALL afficheInfo
    GOTOXY 47,3
	PRINT 'Press a key'
	CALL attentedunetouche
	
	GOTOXY 30,3
	PRINT '                            ' ;on clear le texte
	 
  RET
ENDP

meal PROC;fonction meal 
	GOTOXY 30,3
	PRINT 'It s meal time!'
	MOV indicateur,0 ;on met a zero l'indicateur
	
	CMP discipline ,4 ;si la discipline est faible
	JNL nextMeal
	CMP discipline,0
	JE neVeutPasMangerMeal
	CALL getAlea
	CMP nbAlea,32768 ;une chance sur 2
	JA neVeutPasMangerMeal
	
  nextMeal:
    CMP hungriness,10
	JE attenteEntremeal
	CALL incHun  ;on augmente le fait d'avoir plus fin de 2
	INC indicateur  ;si l'indicateur est a un on arrte la boucle
	CMP indicateur,2
	JNE nextMeal 
	MOV reprimandJustified,0
	JMP attenteEntremeal
	
  neVeutPasMangerMeal:
	GOTOXY 30,3
	PRINT 'RRRHHH, NO!!  '
	MOV reprimandJustified,1
	
  attenteEntremeal:
	CALL afficheInfo
    GOTOXY 47,3
	PRINT 'Press a key'
	CALL attentedunetouche
	
	
	GOTOXY 30,3
	PRINT '                            ' ;on clear le texte
	 
  RET
ENDP


reprimand PROC
    
   GOTOXY 30,3
   CMP reprimandJustified,0
   JNE nextReprimand  
   ;punition non justifié
   PRINT 'punition non justifie'
   CALL decDis ;on diminu de 2 discipine
   CALL decDis
   CALL decHap ;on diminu de 2 hapiness
   CALL decHap
   JMP finReprimand
 nextReprimand:
   ;punition justifié
   PRINT 'punition justifie'  
   CALL incDis
   CALL incDis
   CALL decHap 
   
   
 finReprimand:
    CALL afficheInfo
    GOTOXY 52,3
    PRINT 'press a key'
    CALL attentedunetouche
    GOTOXY 30,3
    PRINT '                                 '
     
  RET  
ENDP

updateAge PROC
    MOV AH, 0h
    INT 1Ah               ;on recupere la date
    MOV AX,DX
        CMP datePrec,0
        JNE nextudateAge
        MOV datePrec,AX
        ADD datePrec,500h
   nextudateAge:  
    CMP DX,datePrec
    JL finUpdate
    
        CMP age,3
        JNL ageMax
          INC age
           GOTOXY 40,3
           PRINT 'LEVEL UP!'
           GOTOXYTama 45,10
           CALL afficheTama
           MOV datePrec,DX 
           ADD datePrec,500h
           CALL decDis
           CALL decHap
           CALL decHun
           CALL decDis
           CALL decHap
           CALL decHun  
           GOTOXY 40,3
           PRINT '         '
           JMP finUpdate
       ageMax: 
        MOV datePrec,DX
        ADD datePrec,400h
        CALL decDis
        CALL decHap
        CALL decHun
    finUpdate:
    CALL afficheInfo
  RET
ENDP
  
affichageDem PROC       ;affichage de l'ecran de démarage
    MOV AH, 09h
    MOV DX, OFFSET demarage
    INT 21h
    RET
ENDP 
      
      
affichagejeu PROC      ;affichage du font du jeu
    MOV AH, 09h
    MOV DX, OFFSET ecrandejeux
    INT 21h
    RET
ENDP 


GOTOXYTama  MACRO   col, row ;positionnement du tamagotchhi
     CALL CLEARTama
     ;on donne les nouveau coordonée 
     MOV posTamaX,col
     MOV posTamaY,row
   
ENDM    


CLEARTama PROC
    CMP age,2
    JL clearTama5
    JNE clearTama6
    MOV CX,6
   clearTama6: 
    MOV CX,7
    DEC posTamaX
    GOTOXY posTamaX,12 
    PUTC 32
    INC posTamaX
    JMP clearTamaProc
   clearTama5:
    MOV CX,5
   clearTamaProc:
     GOTOXY posTamaX,posTamaY
     PRINT '         ';on clear
     DEC posTamaY
     LOOP clearTamaProc         
    
    
   RET
ENDP      



afficheTama PROC      
    
   CMP age,0
   JE affTama1
   CMP age,1
   JE affTama2
   CMP age,2
   JE affTama3
   CMP age,3
   JE affTama4
   
   affTama1:            ;tamagotchi bébé
    GOTOXY posTamaX,posTamaY
    PUTC 32 
    
    INC posTamaY    ;on saute une ligne
    
    GOTOXY posTamaX,posTamaY
    PUTC 220
    PUTC 219
    PUTC 219
    PUTC 220
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 223
    PUTC 223
    
    JMP affFin
    
   affTama2:                ;tamagotchi enfant      
   
    
   GOTOXY posTamaX,posTamaY
    PUTC 32 
    PUTC 32
    PUTC 220
    PUTC 220
    INC posTamaY    
    
    GOTOXY posTamaX,posTamaY
    PUTC 220
    PUTC 223
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 220
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 223
    PUTC 219
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 223
    PUTC 219
    PUTC 219
    PUTC 223
   

    JMP affFin
    
    
   affTama3:                ;tamagotchi teen
       
   GOTOXY posTamaX,posTamaY
    PUTC 32 
    PUTC 32
    PUTC 32
    PUTC 220
    PUTC 220
    INC posTamaY    
    
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 220
    PUTC 223
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 220
    
    INC posTamaY
    
    GOTOXY posTamaX,posTamaY
    
    PUTC 220
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 220
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 223
    PUTC 219
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 32
    PUTC 223
    PUTC 219
    PUTC 219
    PUTC 223
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 223
    PUTC 223
    PUTC 32
    PUTC 32
    PUTC 223
    PUTC 223   
       
        
    JMP affFin 
    
    
   affTama4:                ;tamagotchi adulte
    GOTOXY posTamaX,posTamaY
    PUTC 32 
    PUTC 32
    PUTC 32
    PUTC 220
    PUTC 220
    INC posTamaY    
    
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 220
    PUTC 223
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 220
    
    INC posTamaY
    DEC posTamaX
    GOTOXY posTamaX,posTamaY
    PUTC 220
    PUTC 220
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 220
    PUTC 220  
    INC posTamaX
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 219
    PUTC 219
    PUTC 223
    PUTC 223
    PUTC 219
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 32
    PUTC 219
    PUTC 219
    PUTC 219
    PUTC 219
    
       
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 32
    PUTC 219
    PUTC 32
    PUTC 32
    PUTC 219
    
    INC posTamaY
    GOTOXY posTamaX,posTamaY
    PUTC 32
    PUTC 223
    PUTC 223
    PUTC 32
    PUTC 223
    PUTC 223
   affFin: 
    RET
ENDP            



afficheInfo PROC
   
    GOTOXY 14,4      
    MOV AX,hungriness;on met hungriness dans AX pour lafficher
    CALL PRINT_NUM
    PRINT '/10 '
    
    GOTOXY 14,6
    MOV AX,hapiness;on met hapiness dans AX pour lafficher
    CALL PRINT_NUM
    PRINT '/10 '
    
    GOTOXY 14,8
    MOV AX,discipline;on met discipline dans AX pour lafficher
    CALL PRINT_NUM
    PRINT '/10 '
      
    RET
ENDP               


attentedunetouche PROC 
    
  MOV AH, 0h  ;on recupere  
  INT 16h     ;la touche taper au clavier
              ;si ZF!=0
    
  RET
ENDP     
 
decHap PROC
    CMP hapiness,0
    JE hap1
    DEC hapiness
  hap1:
 RET
ENDP  

decHun PROC
    CMP hungriness,0
    JE hun1
    DEC hungriness
  hun1:
 RET
ENDP

decDis PROC
    CMP discipline,0
    JE dis1
    DEC discipline
  dis1:
 RET
ENDP

incHap PROC
    CMP hapiness,10
    JE hap2
    INC hapiness
  hap2:
 RET
ENDP

incHun PROC
    CMP hungriness,10
    JE hun2
    INC hungriness
  hun2:
 RET
ENDP

incDis PROC
    CMP discipline,10
    JE dis2
    INC discipline 
  dis2:
 RET
ENDP
;define de emu8086.inc
 DEFINE_PRINT_NUM_UNS
 DEFINE_PRINT_NUM
 DEFINE_CLEAR_SCREEN
 DEFINE_PRINT_STRING

   ;debut des variables
   
   ;text du démarage du tamagotchi
demarage DB ' ',177,'  ',177,'  Tamagotchi',010,013
         DB 177,'O',177,177,'O',177,'press a key.',010,013
         DB 6 DUP(177),010,013
         DB 2 DUP(177),2 DUP(176),2 DUP(177),010,013
         DB ' ',4 DUP(177),'$'
        
ecrandejeux DB 218,20 DUP(196),194,57 DUP(196),191,013
            DB 179,'tamagotchi!! HD',5 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,'Hungriness:    ',5 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,'Hapiness:      ',5 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,'Discipline:    ',5 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,'a: snack',12 DUP(032),179,57 DUP(032),179,013
            DB 179,'z: meal ',12 DUP(032),179,57 DUP(032),179,013
            DB 179,'e: play ',12 DUP(032),179,57 DUP(032),179,013
            DB 179,'r: reprimand',8 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,20 DUP(032),179,57 DUP(032),179,013
            DB 179,'echap: quitter ',5 DUP(032),179,57 DUP(032),179,013            
            DB 192,20 DUP(196),193,57 DUP(196),217,'$'   
            
posTamaX DB 31 
posTamaY DB 10
            
hapiness DW 5    ;10 niveau
hungriness DW 5  ;pareil
discipline DW 5  ;pareil            
indicateur DB 0  ;boucleur...            
nbAlea DW 0 
datePrec DW 0 ;date pour la mis a jours du tamagotchi!    
age DW 0 ;age du tamagotchi
reprimandJustified DB 0 ;booléeen si 0 punition non justifier
                        ;si 1 punition justifier            
END 
