-- James Durtka
-- EELE 466 (Computational Computer Architecture)
-- Final project/lab (audio filter option)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Audio_Filter is
	port(
			clk	: in std_logic;
			reset : in std_logic;

			--Avalon Slave-MM interface for writing coefficients
			avs_s1_address : in std_logic_vector(4 downto 0);
			avs_s1_readdata : out std_logic_vector(31 downto 0);
			avs_s1_writedata : in std_logic_vector(31 downto 0);
			avs_s1_read : in std_logic;
			avs_s1_write : in std_logic;
			
			--Avalon-ST Sink Interface
			ast_sink_data : in std_logic_vector(31 downto 0);
			ast_sink_valid : in std_logic;
			ast_sink_error : in std_logic_vector(1 downto 0);
			
			--Avalon-ST Source interface
			ast_source_data : out std_logic_vector(31 downto 0);
			ast_source_valid : out std_logic;
			ast_source_error : out std_logic_vector(1 downto 0)
	);
end entity;

architecture Audio_Filter_arch of Audio_Filter is

	type data_storage is array(0 to 23) of signed(23 downto 0);
	signal coeff			  : data_storage;
	signal data					: data_storage;
	signal N						: unsigned(4 downto 0);
	signal intermed			: signed(47 downto 0);

begin

	--These get passed directly through
	ast_source_valid <= ast_sink_valid;
	ast_source_error <= ast_sink_error;

	ast_source_data <= x"00" & std_logic_vector(intermed(45 downto 22));
	
	--Decide when to bring in new incoming data and output filtered data
	process (clk, reset, ast_sink_valid)
	begin
		--reset state: nothing
		if  (reset = '1') then

			data(0) <= x"000000";
			data(1) <= x"000000";
			data(2) <= x"000000";
			data(3) <= x"000000";
			data(4) <= x"000000";
			data(5) <= x"000000";
			data(6) <= x"000000";
			data(7) <= x"000000";
			data(8) <= x"000000";
			data(9) <= x"000000";
			data(10) <= x"000000";
			data(11) <= x"000000";
			data(12) <= x"000000";
			data(13) <= x"000000";
			data(14) <= x"000000";
			data(15) <= x"000000";
			data(16) <= x"000000";
			data(17) <= x"000000";
			data(18) <= x"000000";
			data(19) <= x"000000";
			data(20) <= x"000000";
			data(21) <= x"000000";
			data(22) <= x"000000";
			data(23) <= x"000000";

		--if valid and clock edge:
		elsif (ast_sink_valid = '1' and rising_edge(clk)) then
			data(23) <= data(22);
			data(22) <= data(21);
			data(21) <= data(20);
			data(20) <= data(19);
			data(19) <= data(18);
			data(18) <= data(17);
			data(17) <= data(16);
			data(16) <= data(15);
			data(15) <= data(14);
			data(14) <= data(13);
			data(13) <= data(12);
			data(12) <= data(11);
			data(11) <= data(10);
			data(10) <= data(9);
			data(9) <= data(8);
			data(8) <= data(7);
			data(7) <= data(6);
			data(6) <= data(5);
			data(5) <= data(4);
			data(4) <= data(3);
			data(3) <= data(2);
			data(2) <= data(1);
			data(1) <= data(0);
			data(0) <= signed(ast_sink_data(23 downto 0));

			intermed <= (
														(coeff(0) * data(0)) +
														(coeff(1) * data(1)) +
														(coeff(2) * data(2)) +
														(coeff(3) * data(3)) +
														(coeff(4) * data(4)) +
														(coeff(5) * data(5)) +
														(coeff(6) * data(6)) +
														(coeff(7) * data(7)) +
														(coeff(8) * data(8)) +
														(coeff(9) * data(9)) +
														(coeff(10) * data(10)) +
														(coeff(11) * data(11)) +
														(coeff(12) * data(12)) +
														(coeff(13) * data(13)) +
														(coeff(14) * data(14)) +
														(coeff(15) * data(15)) +
														(coeff(16) * data(16)) +
														(coeff(17) * data(17)) +
														(coeff(18) * data(18)) +
														(coeff(19) * data(19)) +
														(coeff(20) * data(20)) +
														(coeff(21) * data(21)) +
														(coeff(22) * data(22)) +
														(coeff(23) * data(23))
													);


		end if;
	end process;


	--Decide when to increment the "current index" for the circular buffer
	process (reset, ast_sink_valid)
	begin
		--reset state: nothing
		if  (reset = '1') then

		--N increments on rising data clock edge
		elsif (rising_edge(ast_sink_valid)) then
			if (N = 23) then
				N <= to_unsigned(0,5);
			else
				N <= N + to_unsigned(1,5);
			end if;
		end if;
	end process;

	--Process for writing coefficient registers
	REG_WRITE : process (clk, reset)
	begin
		if (reset = '1') then
			coeff(0) <= x"055555";
			coeff(1) <= x"049e6a";
			coeff(2) <= x"02aaab";
			coeff(3) <= x"000000";
			coeff(4) <= x"fd5555";
			coeff(5) <= x"fb6196";
			coeff(6) <= x"faaaab";
			coeff(7) <= x"fb6196";
			coeff(8) <= x"fd5555";
			coeff(9) <= x"000000";
			coeff(10) <= x"02aaab";
			coeff(11) <= x"049e6a";
			coeff(12) <= x"055555";
			coeff(13) <= x"049e6a";
			coeff(14) <= x"02aaab";
			coeff(15) <= x"000000";
			coeff(16) <= x"fd5555";
			coeff(17) <= x"fb6196";
			coeff(18) <= x"faaaab";
			coeff(19) <= x"fb6196";
			coeff(20) <= x"fd5555";
			coeff(21) <= x"000000";
			coeff(22) <= x"02aaab";
			coeff(23) <= x"049e6a";
		elsif (rising_edge(clk)) then
			--update the selected register with the incoming data
			if (avs_s1_write='1') then
				coeff(to_integer(unsigned(avs_s1_address))) <= signed(avs_s1_writedata(23 downto 0));
			end if;
		end if;
	end process;

	--Process for reading coefficient registers
	REG_READ : process (clk, reset)
	begin
		if (rising_edge(clk)) then
			--output the selected register
			if (avs_s1_read='1') then
				avs_s1_readdata <= x"00" & std_logic_vector(coeff(to_integer(unsigned(avs_s1_address))));
			end if;
		end if;
	end process;
end architecture;