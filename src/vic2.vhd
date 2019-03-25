library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vic is
port(
	clk,rst		: in std_logic;
	irq_serv	: in std_logic;
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
			irq0_memo <= '0';
			irq1_memo <= '0';
			VICPC <= (others => '0');  --erreur
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

	RecepAcqui: process(irq_serv)	--evaluation d'acquittement d'interruption
	begin
		if irq_serv = '1' then
			irq0_memo <= '0';
			irq1_memo <= '0';
			VICPC <= (others => '0');
		end if;
	end process RecepAcqui;
	
	nouveauVICPC: process(irq0_memo,irq1_memo)
	begin
	  if irq0_memo = '1' then
	    VICPC <= x"00000009";
    elsif irq1_memo = '1' then
      VICPC <= x"00000015";
    else
      VICPC <= x"00000000";
    end if;
  end process nouveauVICPC;
--	VICPC <= x"00000009" when irq0_memo = '1' else
--           x"00000015" when irq1_memo = '1';

end ContrIntVect;