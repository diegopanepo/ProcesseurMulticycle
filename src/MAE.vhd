library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAE is
port(
	clk,rst		: in std_logic;
	IRQ,N		: in std_logic;
	inst_reg	: in std_logic_vector (31 downto 0);
	inst_mem	: in std_logic_vector (31 downto 0);
	--commandes a generer
	IRQ_Serv					: out std_logic;
	PCSel					: out std_logic_vector (1 downto 0);
	PCWrEn,LRWrEn,AdrSel	: out std_logic;
	MemRdEn,MemWrEn,IRWrEn	: out std_logic;
	WSel,RegWrEn,ALUSelA	: out std_logic;
	ALUSelB,ALUOP			: out std_logic_vector (1 downto 0);
	CPSRSel,CPSRWrEn		: out std_logic;
	SPSRWrEn,ResWrEn		: out std_logic
);
end entity;

Architecture machine of MAE is

	type ETAT is (ETATnone, ETAT0, ETAT1, ETAT2, ETAT3, ETAT4,
		ETAT5, ETAT6, ETAT7, ETAT8, ETAT9, ETAT10, ETAT11,
		ETAT12, ETAT13, ETAT14, ETAT15, ETAT16, ETAT17);
	signal EtatPresent, EtatFutur :  ETAT;

	type enum_instruction is (noINSTR, MOV, LDR, ADDi, ADDr,
		CMP, STR, BAL, BLT, BX, DEF);
	signal instruc_mem_cour : enum_instruction;
	signal instruc_reg_cour : enum_instruction;

	signal ISR : std_logic := '0';

begin

	process(clk)
	begin
		if rst = '1' then
			EtatPresent <= ETAT0;
		elsif rising_edge(clk) then
			EtatPresent <= EtatFutur;
		end if;
	end process;

	--Logique de l'etat futur
	process(EtatPresent, IRQ)
	begin
		case EtatPresent is
			when ETAT0 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '0';		--
				MemRdEn	<= '1';		--
				MemWrEn	<= '0';
				WSel	<= '-';
				IRWrEn	<= '0';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT1;

			when ETAT1 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '1';		--
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				if (instruc_mem_cour = LDR or instruc_mem_cour = STR or
				instruc_mem_cour = ADDr or instruc_mem_cour = ADDi or
				instruc_mem_cour = CMP or instruc_mem_cour = MOV) then
					EtatFutur <= ETAT2;
				elsif (instruc_mem_cour = BAL or (instruc_mem_cour = BLT and N = '1')) then
					EtatFutur <= ETAT3;
				elsif (instruc_mem_cour = BLT and N = '0') then
					EtatFutur <= ETAT4;
				elsif (instruc_mem_cour = BX and ISR = '1') then
					EtatFutur <= ETAT15;
				elsif (IRQ = '0' and ISR = '0') then
					EtatFutur <= ETAT16;
				else
					EtatFutur <= ETATnone;
				end if;

			when ETAT2 =>
				IRQ_Serv	<= '0';
				PCSel	<= "00";	--
				PCWrEn	<= '1';		--
				AdrSel	<= '-';
				LRWrEn	<= '0';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '0';		--
				ALUSelB	<= "11";	--
				ALUOP	<= "00";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT5;

			when ETAT3 =>
				IRQ_Serv	<= '0';
				PCSel	<= "00";	--
				PCWrEn	<= '1';		--
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				IRWrEn	<= '0';
				MemWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '0';		--
				ALUSelB	<= "10";	--
				ALUOP	<= "00";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT4 =>
				IRQ_Serv	<= '0';
				PCSel	<= "00";	--
				PCWrEn	<= '1';		--
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemWrEn	<= '0';
				MemRdEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '0';		--
				ALUSelB	<= "11";	--
				ALUOP	<= "00";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT5 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				MemWrEn	<= '0';
				RegWrEn	<= '0';
				ALUSelA	<= '-';		--'1';
				ALUSelB	<= "--";	--"01";
				ALUOP	<= "--";	--"10";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				if instruc_mem_cour = LDR or instruc_mem_cour = STR or
				instruc_mem_cour = ADDi then
					EtatFutur <= ETAT6;
				elsif instruc_mem_cour = ADDr then
					EtatFutur <= ETAT7;
				elsif instruc_mem_cour = MOV then
					EtatFutur <= ETAT8;
				elsif instruc_mem_cour = CMP then
					EtatFutur <= ETAT9;
				else
					EtatFutur <= ETATnone;
				end if;

			when ETAT6 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '1';		--
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '1';		--
				ALUSelB	<= "01";	--
				ALUOP	<= "00";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				if instruc_mem_cour = LDR then
					EtatFutur <= ETAT10;
				elsif instruc_mem_cour = STR then
					EtatFutur <= ETAT11;
				elsif instruc_mem_cour = ADDi then
					EtatFutur <= ETAT12;
				else
					EtatFutur <= ETATnone;
				end if;

			when ETAT7 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '1';		--
				RegWrEn	<= '0';
				ALUSelA	<= '1';		--
				ALUSelB	<= "00";	--
				ALUOP	<= "00";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT12;

			when ETAT8 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '1';		--
				MemWrEn	<= '0';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "01";	--
				ALUOP	<= "01";	--
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT12;

			when ETAT9 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemWrEn	<= '0';
				MemRdEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '1';		--
				ALUOP	<= "10";	--
				ALUSelB	<= "01";	--
				CPSRSel	<= '0';		--
				CPSRWrEn<= '1';		--
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT10 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '1';		--
				MemRdEn	<= '1';		--
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUOP	<= "--";
				ALUSelB	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT13;

			when ETAT11 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '1';		--
				MemRdEn	<= '0';
				MemWrEn	<= '1';		--
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT12 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				LRWrEn	<= '0';
				PCWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '1';		--
				RegWrEn	<= '1';		--
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT13 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				AdrSel	<= '-';
				LRWrEn	<= '0';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '0';		--
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT14;

			when ETAT14 =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '0';		--
				RegWrEn	<= '1';		--
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT15 =>
				IRQ_Serv	<= '1';		--
				PCSel	<= "10";	--
				PCWrEn	<= '1';		--
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '1';		--
				CPSRWrEn<= '1';		--
				SPSRWrEn<= '0';		--
				ISR		<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETAT0;

			when ETAT16 =>
				IRQ_Serv	<= '0';
				PCSel	<= "11";	--
				PCWrEn	<= '0';		--
				LRWrEn	<= '1';		--
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';		--
				SPSRWrEn<= '1';		--
				ResWrEn	<= '0';
				EtatFutur <= ETAT17;

			when ETAT17 =>
				IRQ_Serv	<= '0';
				PCSel	<= "11";	--
				PCWrEn	<= '1';		--
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				ISR		<= '1';
				EtatFutur <= ETAT0;

			when others =>
				IRQ_Serv	<= '0';
				PCSel	<= "--";
				PCWrEn	<= '0';
				LRWrEn	<= '0';
				AdrSel	<= '-';
				MemRdEn	<= '0';
				MemWrEn	<= '0';
				IRWrEn	<= '0';
				WSel	<= '-';
				RegWrEn	<= '0';
				ALUSelA	<= '-';
				ALUSelB	<= "--";
				ALUOP	<= "--";
				CPSRSel	<= '-';
				CPSRWrEn<= '0';
				SPSRWrEn<= '0';
				ResWrEn	<= '0';
				EtatFutur <= ETATnone;

		end case;
	end process;

	--process(inst_reg)
	--begin
	process(inst_reg)
	begin
		case inst_reg(27 downto 26) is
			when "00" =>
				case inst_reg(25 downto 21) is
					when "10100"	=> instruc_mem_cour <= ADDi;
					when "00100"	=> instruc_mem_cour <= ADDr;
					when "11101"	=> instruc_mem_cour <= MOV;
					when "11010"	=> instruc_mem_cour <= CMP;
					when others		=> report "Instruction invalide";
									--instr_courante <= 'X';
					end case;
			when "01" =>
				if inst_reg(20) = '1' then
					instruc_mem_cour <= LDR;
				elsif inst_reg(20) = '0' then
					instruc_mem_cour <= STR;
				else report "Instruction invalide";
						--instr_courante <= 'X';
				end if;
			when "10" =>
				if inst_reg(30) = '1' then
					instruc_mem_cour <= BAL;
				elsif inst_reg(30) = '0' then
					instruc_mem_cour <= BLT;
				else
					report "Instruction invalide";--instr_courante <= 'X';
				end if;
			when others	=>
				report "Instruction invalide"; --instr_courante <= 'X';
		end case;
	end process;

	--process(inst_mem)
	--begin

end machine;
