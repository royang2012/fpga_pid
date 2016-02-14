----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2016 10:00:16 AM
-- Design Name: 
-- Module Name: MHz_divider - Behavioral
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

entity MHz_divider is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           MCLK : out STD_LOGIC);
end MHz_divider;

architecture Behavioral of MHz_divider is
signal counter      : std_logic_vector(5 downto 0);
signal sclk         : std_logic:='0';
constant hundred    : std_logic_vector(5 downto 0):="110001"; 
begin
clock_divider: process(RST, CLK)
begin
    if (RST='1') then
        counter <= (others=>'0');
        sclk <= '0';         
    else if (rising_edge(CLK)) then 
        if (counter=hundred) then              
            counter <= (others=>'0'); 
            sclk <= NOT sclk;
        else
            counter <= counter + 1;               
        end if;        
        end if;
    end if; 
end process;
    MCLK <= sclk;
end Behavioral;
