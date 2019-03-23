library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vic is
port(
	clk,rst		: in std_logic;
	iqr_serv	: in std_logic;
	irq0,irq1	: in std_logic;
	IRQ			: out std_logic;
	VICPC		: out std_logic_vector (31 downto 0)
);
end entity;

Architecture ContrIntVect of vic is
	signal irq0_memo, irq1_memo : std_logic;
		--l'etat haut signale une requete d'interruption
begin

	process(clk,rst)
	begin
		if rst = '1' then
			IRQ <= '0';
			VICPC <= (others => '0');
		elsif rising_edge(clk) then
			IRQ <= irq0_memo or irq1_memo;
		end if;
	end process;

	Interr0: process(irq0)	--evaluation d'interruption 0
	begin
		if irq0 = '1' then
			irq0_memo <= '1';
		end if;
	end process Interr0;

	Interr1: process(irq1)	--evaluation d'interruption 1
	begin
		if irq1 = '1' then
			irq1_memo <= '1';
		end if;
	end process Interr1;

	RecepAcqui: process(iqr_serv)	--evaluation d'acquittement d'interruption
	begin
		if iqr_serv = '1' then
			irq0_memo <= '0';
			irq1_memo <= '0';
			VICPC <= (others => '0');
		end if;
	end process RecepAcqui;

	VICPC <= x"00000009" when irq0_memo = '1';
	VICPC <= x"00000015" when irq1_memo = '1';

end ContrIntVect;
