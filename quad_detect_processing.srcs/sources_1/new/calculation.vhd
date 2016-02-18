----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2016 01:09:41 PM
-- Design Name: 
-- Module Name: calculation - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity calculation is
    Port ( lr_in : in STD_LOGIC_VECTOR (11 downto 0);
           tb_in : in STD_LOGIC_VECTOR (11 downto 0);
           sum_in : in STD_LOGIC_VECTOR (11 downto 0);
           lr_out : out STD_LOGIC_VECTOR (11 downto 0);
           tb_out : out STD_LOGIC_VECTOR (11 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           en_cal : in STD_LOGIC;
           BYPASS : in STD_LOGIC;
           DONE : out STD_LOGIC);
end calculation;

architecture Behavioral of calculation is
COMPONENT div_gen_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
  );
END COMPONENT;

signal shift_counter    : std_logic_vector(4 downto 0):="00000";
signal tvalid           : std_logic;
signal tvalid2          : std_logic;
signal divisor          : std_logic_vector(15 downto 0);
signal dividend1        : std_logic_vector(23 downto 0);
signal dividend2        : std_logic_vector(23 downto 0);

signal division_out1    : std_logic_vector(39 downto 0);
signal division_out2    : std_logic_vector(39 downto 0);
begin

    divisor <= "0000"&sum_in;    
    dividend1 <= lr_in&"000000000000";
    dividend2 <= tb_in&"000000000000";
lr_division1: div_gen_0 port map(
    CLK,
    en_cal,
    divisor,
    en_cal,
    dividend1,
    tvalid,
    division_out1);
    
tb_division2: div_gen_0 port map(
    CLK,
    en_cal,
    divisor,
    en_cal,
    dividend2,
    tvalid2,
    division_out2);
        
counter: process(RST,CLK)
    begin
        if RST = '1' then
            shift_counter <= "00000";
            DONE <= '0';
        elsif en_cal = '0' then
            shift_counter <= "00000";
            DONE <= '0';
        elsif rising_edge(CLK) then
            if shift_counter = "10001" then
                shift_counter <= "00000";    
                DONE <= '1';                       
            else shift_counter <= shift_counter + '1';
            end if;
        end if;
    end process;

--    with BYPASS select lr_out <=
--        division_out1(27 downto 16)  when '0',
--        lr_in                        when '1';

--    with BYPASS select tb_out <=
--        division_out2(27 downto 16)  when '0',
--        tb_in                        when '1';      
lr_actuator: process(lr_in,BYPASS,RST,division_out1)
    begin
    if RST = '1' then
        lr_out <= x"000";
    elsif BYPASS = '1' then
        lr_out <= lr_in;
    elsif lr_in >= sum_in then
        lr_out <= x"fff";
    else
        lr_out <= division_out1(27 downto 16);
    end if;
    end process;

tb_actuator: process(tb_in,BYPASS,RST,division_out2)
    begin
    if RST = '1' then
        tb_out <= x"000";
    elsif BYPASS = '1' then
        tb_out <= tb_in;
    elsif lr_in >= sum_in then
        tb_out <= x"fff";
    else
        tb_out <= division_out2(27 downto 16);
    end if;
    end process;
    
end Behavioral;
