library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
port(
    OP : in std_logic_vector (1 downto 0);
    A,B : in std_logic_vector (31 downto 0);
    Y : out std_logic_vector (31 downto 0);
    N : out std_logic
);
end entity;

Architecture Arch_Alu of alu is
  signal S : std_logic_vector (31 downto 0);
begin
	
	S <= std_logic_vector(unsigned(A)+unsigned(B)) when OP="00" else
		B   when OP="01" else
		std_logic_vector(unsigned(A)-unsigned(B)) when OP="10" else
		A   when OP="11" ;
	N <= '1' when S(31)='1' else
		'0' when S(31)='0';
	Y <= S;

end architecture;

