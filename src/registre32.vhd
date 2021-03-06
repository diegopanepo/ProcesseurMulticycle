library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registre32 is
port(
	clk,rst	: in std_logic;
	DATAIN	: in std_logic_vector (31 downto 0);
	DATAOUT	: out std_logic_vector (31 downto 0)
);
end entity;

Architecture reg of registre32 is

	signal registr : std_logic_vector (31 downto 0);

begin

	process(clk,rst)
	begin
		if rst = '1' then
			registr <= (others => '0');
		elsif rising_edge(clk) then
			registr <= DATAIN;
		end if;
	end process;

	DATAOUT <= registr;

end reg;
