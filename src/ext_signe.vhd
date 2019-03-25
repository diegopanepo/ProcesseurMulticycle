library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ext_signe is
generic(
	N : natural
);
port(
	E : in std_logic_vector (N-1 downto 0);
	S : out std_logic_vector (31 downto 0)
);
end entity;

Architecture extender of ext_signe is
	signal int : std_logic_vector (31 downto 0);
begin

	S <= int;

	process(E)
	begin
		for i in 31 downto N loop
			int(i) <= E(N-1);
		end loop;
		for i in N-1 downto 0 loop
			int(i) <= E(i);
		end loop;
	end process;

end extender;
