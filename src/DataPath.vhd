------------------------------------------------------------------
--																--
--					PROCESSEUR MULTI-CYCLES						--
--						CHEMIN DE DONNEES						--
--																--
---						(c) 2010-2012							--
-- 		A.Mocco, N.Hamila, M.Fonseca, J.Denoulet, P.Garda		--
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity DataPath is
port(
		clk,rst		: in std_logic;								-- Horloge + Reset Asynchrone

		-- Gestion des Interruptions
		irq0,irq1	: in std_logic;								-- Boutons Interruptions Externes
		irq     		: out std_logic;								-- Requete Interruption Transmise par le VIC
		irq_serv		: in std_logic;  								-- Acquittement Interruption

		-- Instructions
		Inst_Mem   	: out std_logic_vector(31 downto 0);	-- Instruction a Decoder (MEMOIRE)
		Inst_Reg    : out std_logic_vector(31 downto 0);	-- Instruction a Decoder (REG INST)
		N        	: out std_logic; 								-- Flag N memorise dans Registre d'Etat

		-- Memoire Interne
		AdrSel 		: in std_logic; 								-- Commande Mux Bus Adresses
		MemRdEn   	: in std_logic;								-- Read Enable
		MemWrEn    	: in std_logic;								-- Write Enable

		-- Registre Instruction
		IrWrEn     	: in std_logic;								-- Write Enable

		-- Banc de Registres
		WSel			: in std_logic;								-- Commande Mux Bus W
		RegWrEn 		: in std_logic;								-- Write Enable

		--signaux de controle pour l'alu
		AluSelA 		: in std_logic;								-- Selection Entree A ALU
		AluSelB  	: in std_logic_vector(1 downto 0);		-- Selection Entree B ALU
		AluOP    	: in std_logic_vector(1 downto 0);		-- Selecttion Operation ALU

		-- Registres d'Etat (CPSR, SPSR)
		CpsrSel		: in std_logic; 								-- Mux Selection Entree CPSR
		CpsrWrEn		: in std_logic;								-- Write Enable CPSR
		SpsrWrEn		: in std_logic;								-- Write Enable SPSR

		-- Registres PC et LR
		PCSel 		: in std_logic_vector(1 downto 0);		-- Selection Entree Registre PC
		PCWrEn 		: in std_logic;								-- Write Enable PC
		LRWrEn 		: in std_logic;								-- Write Enable LR

		-- Registre Resultat
		Res    		: out std_logic_vector(31 downto 0);	-- Sortie Registre Resultat
		ResWrEn		: in std_logic									-- Write Enable
  );
end DataPath;


architecture archi of DataPath is

------------------------------------------------------------------------------
-- DECLARATION COMPONENTS DE LA PARTIE OPERATIVE

	----------------------------------------------------
	-- Controleur d'Interruptions
	component vic is
	port	(
		clk        	: in 	std_logic;
		rst      	: in	std_logic;
		irq_serv   	: in	std_logic;
		irq0, irq1 	: in	std_logic;
		IRQ			: out	std_logic;
		VICPC			: out	std_logic_vector(31 downto 0)
	);
	end component vic;
	----------------------------------------------------

	----------------------------------------------------
	-- Memoire Interne
	component memoire IS
	PORT (
		clock		: IN 	STD_LOGIC ;
		data		: IN 	STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdaddress: IN 	STD_LOGIC_VECTOR (5 DOWNTO 0);
		rden		: IN 	STD_LOGIC  := '1';
		wraddress: IN 	STD_LOGIC_VECTOR (5 DOWNTO 0);
		wren		: IN 	STD_LOGIC  := '1';
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END component memoire;
	----------------------------------------------------

	----------------------------------------------------
	-- Registre
	component registre32 is
	port  (
		clk,rst	: in 	std_logic;
		DATAIN	: in 	std_logic_vector(31 downto 0);
		DATAOUT	: out std_logic_vector(31 downto 0)
	);
	end component registre32;
	----------------------------------------------------

	----------------------------------------------------
	-- Registre avec Commande de Chargement
	component registre32Ld is
	port  (
		rst,clk,we	: in 	std_logic;
		DATAIN		: in 	std_logic_vector(31 downto 0);
		DATAOUT		: out std_logic_vector(31 downto 0)
	);
	end component registre32Ld;
	----------------------------------------------------

	----------------------------------------------------
	-- Banc de Registres
	component banc_registr is
	port(
      clk,rst : in std_logic;
      W       : in std_logic_vector (31 downto 0);
      RA,RB,RW: in std_logic_vector (3 downto 0);
      WE      : in std_logic;
      A,B     : out std_logic_vector (31 downto 0)

	);
	end component banc_registr;
	----------------------------------------------------

	----------------------------------------------------
	-- Mux 2 -> 1
	component multip2v1 is
	generic (N: natural:=32);
	port	(
		COM	: in 	std_logic;
		A,B	: in 	std_logic_vector (N-1 downto 0);
		S		: out std_logic_vector (N-1 downto 0)
	);
	end component multip2v1;
	----------------------------------------------------

	----------------------------------------------------
	-- Mux 4 -> 1
	component multip4v1 is
	generic (N: natural:=32);
	port	(
		COM		: in 	std_logic_vector(1 downto 0);
		A,B,C,D	: in 	std_logic_vector (N-1 downto 0);
		S			: out std_logic_vector (N-1 downto 0)
	);
	end component multip4v1;
	----------------------------------------------------

	----------------------------------------------------
	-- Extenseur 32 Bits
	component ext_signe is
	generic(N: natural:=8);
	port(
		E	: in 	std_logic_vector(N-1 downto 0);
		S	: out std_logic_vector(31 downto 0)
	);
	end component ext_signe;
	----------------------------------------------------

	----------------------------------------------------
	-- ALU
	component alu is
	port	(
		OP : in std_logic_vector (1 downto 0);
 		A,B : in std_logic_vector (31 downto 0);
 		Y : out std_logic_vector (31 downto 0);
      N : out std_logic
	);
	end component alu;
	----------------------------------------------------
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION SIGNAUX INTERNES


	-- Memoire Interne
	signal MemAdr    :std_logic_vector(5 downto 0);	-- Bus Adresses Memoire
	signal MemDataOut       :std_logic_vector(31 downto 0); -- Bus Donnees LEcture Memoire

	-- Registres LR, A, B, ALU, IR, et DR
	signal RegA	: std_logic_vector(31 downto 0);
	signal RegB	: std_logic_vector(31 downto 0); -- Registre B + Bus Donnees Memoire
	signal RegALU  : std_logic_vector(31 downto 0);
	signal LR          :std_logic_vector(31 downto 0);
	signal IR:std_logic_vector(31 downto 0);
	signal DR:std_logic_vector(31 downto 0);

	-- Registre PC
	signal PC        : std_logic_vector (31 downto 0);
	signal PCIn            :std_logic_vector(31 downto 0); -- Entree du Registre PC

	-- Banc de Registres
	signal MuxBusW   : std_logic_vector(31 downto 0);
	signal MuxRBSel:std_logic;
	signal MuxBusRB  :std_logic_vector(3 downto 0);
	signal BusA      : std_logic_vector(31 downto 0);
	signal BusB      : std_logic_vector(31 downto 0);

	-- Extenseurs 32 bits
	signal Imm8_32  :std_logic_vector(31 downto 0);
	signal Imm24_32: std_logic_vector(31 downto 0);

	-- Sortie du VIC
	signal VICAdr          :std_logic_vector(31 downto 0); -- Sortie du VIC

	-- ALU
	signal AluOut     :std_logic_vector(31 downto 0);	-- Sortie
	signal AluInA,AluInB:std_logic_vector(31 downto 0);-- Entrees
	signal plus1    :std_logic_vector(31 downto 0); -- Constante: 1
	signal FlagN: std_logic;	-- Drapeau N

	-- Registres d'Etat (SPSR et CPSR)
	signal CpsrFlag   : std_logic_vector(31 downto 0); -- CPSR avec Flag a jour
	signal CpsrIn  :std_logic_vector(31 downto 0);	-- Entree Registre CPSR
	signal Cpsr :std_logic_vector(31 downto 0);	-- Registre CPSR
	signal Spsr : std_logic_vector(31 downto 0); 	-- Registre SPSR

begin

--Controleur d'Interruptions
VIC0:	vic port map(
		clk		=>	clk,
		rst		=>	rst,
		irq_serv	=>	irq_serv,
		irq0		=>	irq0,
		irq1		=>	irq1,
		irq		=>	irq,
		VICPC		=>	VICAdr );

-- Mux Selection PC
MuxPC : multip4v1 port map(
			A				=>	AluOut,
			B				=>	RegALU,
			C				=>	LR,
			D				=>	VICAdr,
			COM			  	=>	PCSel,
			S				=>	PCIn);

-- Registre PC
RegPC : registre32Ld port map(
			DATAIN		=>	PCIn,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	PCWrEn,
			DATAOUT		=>	PC);

-- Link Register
LR0 : registre32Ld port map(
			DATAIN		=>	PC,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	LRWrEn,
			DATAOUT			=>	LR);

MuxMem: multip2v1 generic map(6) port map(
			A				=>	PC(5 downto 0),
			B				=>	RegALU(5 downto 0),
			COM			=>	AdrSel,
			S				=>	MemAdr);

-- Memoire Interne
Mem:	memoire port map(
			clock			=>	clk,
			data			=>	RegB,
			rdaddress	=>	MemAdr,
			rden			=>	MemRdEn,
			wraddress	=>	MemAdr,
			wren			=>	MemWrEn,
			q				=>	MemDataOut);

-- Registre IR
RegistreInstr	: registre32Ld port map(
			DATAIN		=>	MemDataOut,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	IrWrEn,
			DATAOUT		=>	IR);

-- Registre DR
RegistreData  	: registre32 port map(
			DATAIN		=>	MemDataOut,
			rst			=>	rst,
			clk			=>	clk,
			DATAOUT		=>	DR);

--instanciation du mux2v1s32 qui sert � selectionner busW
MuxW0	: multip2v1 port map(
			A				=>	DR,
			B				=>	RegALU,
			COM			=>	WSel,
			S				=>	MuxBusW);

-- MuxRBSel=1 si STORE
MuxRBSel <= NOT(IR(27) OR IR(20)) AND IR(26);

-- Mux Bus W du Banc de Registres
MuxRB0 : multip2v1 generic map(4) port map(
			A				=>	IR(3 downto 0),
			B				=>	IR(15 downto 12),
			COM			=>	MuxRBSel,
			S				=>	MuxBusRB);

-- Banc de Registres
BancReg: banc_registr port map(
			clk			  =>	clk,
			rst     =>      rst,
			W				=>	MuxBusW,
			RA				=>	IR(19 downto 16),
			RB				=>	MuxBusRB,
			RW				=>	IR(15 downto 12),
			WE				=>	RegWrEn,
			A				=>	BusA,
			B				=>	BusB);

-- Registre A
RegA0: registre32 port map(
			DATAIN		=>	BusA,
			rst			=>	rst,
			clk			=>	clk,
			DATAOUT		=>	RegA);

-- Registre B
RegB0: registre32 port map(
			DATAIN		=>	BusB,
			rst			=>	rst,
			clk			=>	clk,
			DATAOUT		=>	RegB);

-- Extenseur 8=>32
Ext8_32 : ext_signe port map(
			E				=>	IR(7 downto 0),
			S				=>	Imm8_32);

-- Extenseur 24=>32
Ext24_32: ext_signe generic map(24) port map(
			E				=>	IR(23 downto 0),
			S				=>	Imm24_32);

-- Mux Selection Entree A ALU
MuxAluA: multip2v1 port map(
			A				=>	PC,
			B				=>	RegA,
			COM			=>	AluSelA,
			S				=>	AluInA);

-- Constante a 1 pour Operation ALU
plus1<=X"00000001";

-- Mux Selection Entree B ALU
MuxAluB : Multip4v1 port map(
			A				=>	RegB,
			B				=>	Imm8_32,
			C				=>	Imm24_32,
			D				=>	plus1,
			COM			=>	AluSelB,
			S				=>	AluInB);

-- ALU
ALU0 : alu port map(
			A				=> AluInA,
			B				=>	AluInB,
			OP				=>	AluOP,
			Y				=>	AluOut,
			N				=>	FlagN);

-- Registre ALU
RegALU0: registre32 port map(
			DATAIN		=>	AluOut,
			rst			=>	rst,
			clk			=>	clk,
			DATAOUT		=>	RegALU);

CpsrFlag<=FlagN & Cpsr(30 downto 0);

-- Mux CPSR
cpsrmux : multip2v1 port map(
			A				=>	CpsrFlag,
			B				=>	Spsr,
			COM			=>	CpsrSel,
			S				=>	CpsrIn);

-- Registre CPSR
CPSR0: registre32Ld port map(
			DATAIN		=>	CpsrIn,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	CpsrWrEn,
			DATAOUT		=>	cpsr);

-- Registre SPSR
SPSR0: registre32Ld port map(
			DATAIN		=>	Cpsr,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	SpsrWrEn,
			DATAOUT		=>	Spsr);

-- Registre Resultat
RegRes: registre32Ld port map(
			DATAIN		=>	RegB,
			rst			=>	rst,
			clk			=>	clk,
			we				=>	ResWrEn,
			DATAOUT		=>	Res);


-- Sortie Instruction vers Machine a Etat
Inst_Mem	<=	MemDataOut;
Inst_Reg	<=	IR;
N			<=	Cpsr(31);

end archi;
