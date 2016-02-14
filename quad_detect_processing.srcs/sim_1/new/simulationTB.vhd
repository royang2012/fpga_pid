----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2016 02:22:02 PM
-- Design Name: 
-- Module Name: simulationTB - Behavioral
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

entity simulationTB is
--  Port ( );
end simulationTB;

architecture Behavioral of simulationTB is
component process_control is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           START : in STD_LOGIC;
           BYPASS : in STD_LOGIC;
           DATA_AD1_1 : in STD_LOGIC;
           DATA_AD1_2 : in STD_LOGIC;
           DATA_AD2_1 : in STD_LOGIC;
           DATA_AD2_2 : in STD_LOGIC;                      
           SCLK_AD1 : out STD_LOGIC;
           SCLK_AD2 : out STD_LOGIC;
           nCS_AD1 : out STD_LOGIC;
           nCS_AD2 : out STD_LOGIC;
           SCLK_DA1 : out STD_LOGIC;
           SCLK_DA2 : out STD_LOGIC;
           nCS_DA1 : out STD_LOGIC;
           nCS_DA2 : out STD_LOGIC;
           nLDAC1 : out STD_LOGIC;
           nLDAC2 : out STD_LOGIC;
           DATA_DA1 : out STD_LOGIC;
           DATA_DA2 : out STD_LOGIC;
           lr   : out STD_LOGIC_VECTOR(11 downto 0);
           sum   : out STD_LOGIC_VECTOR(11 downto 0);
           d   : out STD_LOGIC_VECTOR(15 downto 0);
           mmclock : out std_logic;
           state_indi : out std_logic_vector(2 downto 0));
end component;
signal       CLK : STD_LOGIC;
signal       RST : STD_LOGIC;
signal       START : STD_LOGIC:='1';
signal       BYPASS : STD_LOGIC:='0';
signal       DATA_AD1_1 : STD_LOGIC;
signal       DATA_AD1_2 : STD_LOGIC;
signal       DATA_AD2_1 : STD_LOGIC;
signal       DATA_AD2_2 : STD_LOGIC;                      
signal       SCLK_AD1 : STD_LOGIC;
signal       SCLK_AD2 : STD_LOGIC;
signal       nCS_AD1 : STD_LOGIC;
signal       nCS_AD2 : STD_LOGIC;
signal       SCLK_DA1 : STD_LOGIC;
signal       SCLK_DA2 : STD_LOGIC;
signal       nCS_DA1 : STD_LOGIC;
signal       nCS_DA2 : STD_LOGIC;
signal       nLDAC1 : STD_LOGIC;
signal       nLDAC2 : STD_LOGIC;
signal       DATA_DA1 : STD_LOGIC;
signal       DATA_DA2 : STD_LOGIC;
signal      lr   : STD_LOGIC_VECTOR(11 downto 0);
signal      sum   : STD_LOGIC_VECTOR(11 downto 0);
signal      d   : STD_LOGIC_VECTOR(15 downto 0);
signal       mmclock : STD_LOGIC;
signal      state_indi : std_logic_vector(2 downto 0);
begin
iotest: process_control port map(
           CLK,
           RST,
           START,
           BYPASS,
           DATA_AD1_1,
           DATA_AD1_2,
           DATA_AD2_1,
           DATA_AD2_2,                
           SCLK_AD1,
           SCLK_AD2,
           nCS_AD1,
           nCS_AD2,
           SCLK_DA1,
           SCLK_DA2,
           nCS_DA1,
           nCS_DA2 ,
           nLDAC1,
           nLDAC2,
           DATA_DA1,
           DATA_DA2,
           lr,
           sum,
           d,
           mmclock,
           state_indi);
           
           process
           begin
               CLK <= '0';
               wait for 5 ns;
               CLK <= '1';
               wait for 5 ns;
           end process;    
           
           goon: process
           begin
               wait for 20ns;
               RST <= '1';
               wait for 20ns;
               RST <= '0';
               wait for 700ns;
               DATA_AD1_1 <= '1';
               DATA_AD2_1 <= '1';
               wait for 150ns;
               DATA_AD1_1 <= '0';
               wait for 50ns;
               DATA_AD2_1 <= '0';               
               wait;
           end process; 
end Behavioral;
