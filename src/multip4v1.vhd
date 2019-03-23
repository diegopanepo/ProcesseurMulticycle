library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multip4v1 is
generic(
	N : natural
);
port(
	COM		: in std_logic_vector (1 downto 0);
	A,B,C,D	: in std_logic_vector (N-1 downto 0);
	S		: out std_logic_vector (N-1 downto 0)
);
end entity;

Architecture mult of multip4v1 is

begin

	S <= A when COM = "00" else	--ALU
		B when COM = "01" else	--ALUOUT
		C when COM = "10" else	--LR
		D when COM = "11";		--VIC

end mult;
