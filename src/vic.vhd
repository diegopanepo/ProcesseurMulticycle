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
	signal irq0_n, irq1_n		: std_logic;
	signal irq0_n_1, irq1_n_1	: std_logic;
	signal irq0_memo, irq1_memo : std_logic;
		--l'etat haut signale une requete d'interruption
begin

	process(clk,rst)
	begin
		if rst = '1' then
			IRQ = '1';
			irq0_n <= '0';
			irq1_n <= '0';
			irq0_n_1 <= '0';
			irq1_n_1 <= '0';
			irq0_memo <= '0';
			irq1_memo <= '0';
			VICPC <= (others => '0');
		elsif rising_edge(clk) then
			irq0_n_1 <= irq0_n;
			irq1_n_1 <= irq1_n;
			irq0_n <= irq0;
			irq1_n <= irq1;
		end if;
	end process;
	
	process(irq0_n,irq1_n,irq0_n_1,irq1_n,irq_serv)
	begin
		if irq_serv = '1' then
			irq0_memo <= '0';
			irq1_memo <= '0';
		end if;
		if irq0_n = '1' and irq0_n_1 = '0' then
			irq0_memo <= '1';
		elsif irq1_n = '1' and irq1_n_1 = '0' then
			irq1_memo <= '1';
		end if;
	end process;
	
	process(irq0_memo,irq1_memo)
	begin
		if irq0_memo = '1' then
			VICPC <= x"00000009";
		elsif irq1_memo = '1' then
			VICPC <= x"00000015";
		else
			VICPC <= x"00000000";
		end if;
	end process;

end ContrIntVect;