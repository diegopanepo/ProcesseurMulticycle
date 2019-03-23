library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multip2v1 is
generic(
	N : natural
);
port(
	COM		: in std_logic;
	A,B		: in std_logic_vector (N-1 downto 0);
	S		: out std_logic_vector (N-1 downto 0)
);
end entity;

Architecture mult of multip2v1 is

begin

	S <= A when COM = '0' else
		B when COM = '1';

end mult;
