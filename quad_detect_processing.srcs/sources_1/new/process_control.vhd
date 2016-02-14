----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2016 01:00:56 PM
-- Design Name: 
-- Module Name: process_control - Behavioral
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

entity process_control is
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
end process_control;

architecture Behavioral of process_control is
component pmodad1 is
  Port    (    
  --General usage
    CLK      : in std_logic;         
    RST      : in std_logic;
     
  --Pmod interface signals
    SDATA_1  : in std_logic;
    SDATA_2  : in std_logic;
    SCLK     : out std_logic;
    nCS      : out std_logic;
        
    --User interface signals
    DATA_1   : out std_logic_vector(11 downto 0);
    DATA_2   : out std_logic_vector(11 downto 0);
    START    : in std_logic; 
    DONE     : out std_logic
            );
end component;

component pmodda3 is
  Port    (    
  --General usage
    CLK      : in std_logic;         
    RST      : in std_logic;
     
  --Pmod interface signals
    DATA     : in std_logic_vector(15 downto 0);
    SCLK     : out std_logic;
    nCS      : out std_logic;
    nLDAC    : out std_logic;
  
  --User interface signals
    INDATA   : out std_logic; 
    START    : in std_logic; 
    DONE     : out std_logic
            );
end component;

component calculation is
    Port ( lr_in : in STD_LOGIC_VECTOR (11 downto 0);
           tb_in : in STD_LOGIC_VECTOR (11 downto 0);
           sum_in : in STD_LOGIC_VECTOR (11 downto 0);
           lr_out : out STD_LOGIC_VECTOR (15 downto 0);
           tb_out : out STD_LOGIC_VECTOR (15 downto 0);                      
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           en_cal   :in STD_LOGIC;
           BYPASS   :in STD_LOGIC;
           DONE : out STD_LOGIC);
end component;

component MHz_divider is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           MCLK : out STD_LOGIC);
end component;

type states is (Idle,   
                ADC,                
                DataCal);                  
signal current_state: states;
signal next_state   : states;

signal MCLK         : std_logic;
signal dacounter    : std_logic_vector(3 downto 0);
signal start_ad1    : std_logic;
signal done_ad1     : std_logic;
signal start_ad2    : std_logic;
signal done_ad2     : std_logic;

signal start_da1    : std_logic;
signal done_da1     : std_logic;
signal start_da2    : std_logic;
signal done_da2     : std_logic;

signal done_cal     : std_logic;
signal en_cal       : std_logic;

signal input_data1  : std_logic_vector(11 downto 0);
signal input_data2  : std_logic_vector(11 downto 0);
signal input_data3  : std_logic_vector(11 downto 0);
signal input_data4  : std_logic_vector(11 downto 0);

signal output_data1 : std_logic_vector(15 downto 0);
signal output_data2 : std_logic_vector(15 downto 0);

begin
lr <= input_data1;
sum<= input_data3;
d<=output_data1;
mmclock<=MCLK;
--state_indi <= start_ad1&en_cal&start_da1;
state_indi <= dacounter(2 downto 0);
lrbt_data_input: pmodad1 port map(
    CLK,
    RST,
    DATA_AD1_1,
    DATA_AD1_2,
    SCLK_AD1,
    nCS_AD1,
    input_data1,
    input_data2,
    start_ad1,
    done_ad1);

sum_data_input: pmodad1 port map(
    CLK,
    RST,
    DATA_AD2_1,
    DATA_AD2_2,
    SCLK_AD2,
    nCS_AD2,
    input_data3,
    input_data4,
    start_ad2,
    done_ad2);    
    
lr_output: pmodda3 port map(
    CLK,
    RST,
    output_data1,
    SCLK_DA1,
    nCS_DA1,
    nLDAC1,
    DATA_DA1,
    start_da1,
    done_da1);

tb_output: pmodda3 port map(
    CLK,
    RST,
    output_data2,
    SCLK_DA2,
    nCS_DA2,
    nLDAC2,
    DATA_DA2,
    start_da2,
    done_da2);    

MHz_clock: MHz_divider port map(
    CLK,
    RST,
    MCLK);

data_cal: calculation port map(
    input_data1,
    input_data2,
    input_data3,
    output_data1,
    output_data2,
    RST,
    CLK,
    en_cal,
    BYPASS,
    done_cal);

SYNC_PROC: process (CLK,RST)
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then
            current_state <= Idle;
         else
            current_state <= next_state;
         end if;        
      end if;
   end process;
       
STATE_DECODE: process(current_state)
    begin
        if current_state = Idle then
            start_ad1 <= '0';
            start_ad2 <= '0';
            en_cal <= '0';
         elsif current_state = ADC then
            start_ad1 <= '1';
            start_ad2 <= '1';
            en_cal <= '1';
        elsif current_state = DataCal then
            start_ad1 <= '0';
            start_ad2 <= '0';
            en_cal <= '1';
         end if;
    end process;    
                                           
NEXT_STATE_DECODE: process (current_state, START, done_ad1, done_da1, MCLK)
    begin        
        next_state <= current_state;  -- default is to stay in current state     
        case(current_state) is
            when Idle => 
                if START = '1' then
                    if rising_edge(MCLK) then
                        next_state <= ADC;
                    end if;
                end if;
            when ADC =>
                if rising_edge(done_ad1) then
                    next_state <= DataCal;
                end if;
            when DataCal =>          
                if rising_edge(MCLK) then
                    next_state <= ADC;
                end if;
            when others =>
                next_state <= Idle;                
        end case;                     
    end process;  

delay_counter: process(CLK, RST, start_ad1,done_ad1)
    begin
        if RST = '1' then
            start_da1 <= '0';
            start_da2 <= '0';
            dacounter <= "0000";
        elsif rising_edge(done_ad1) then           
            start_da1 <= '0';
            start_da2 <= '0';    
            dacounter <= "0000";        
        elsif start_ad1 = '1' then
            if rising_edge(CLK) then
                if dacounter = "1001" then
                    start_da1 <= '1';
                    start_da2 <= '1';      
                    dacounter <= "0000";         
                else
                dacounter <= dacounter + '1'; 
                end if;
            end if;
        end if;
    end process;
end Behavioral;
