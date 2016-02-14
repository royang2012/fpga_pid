-------------------------------------------------------------------------
--    AD1RefComp.VHD
-------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------
--Title         : AD1 Reference Component
--
--   Inputs         : 5
--   Outputs        : 5
--
--   Description: This is the AD1 Reference Component entity. The input
--                ports are a 50 MHz clock and an asynchronous reset 
--                button along with the data from the ADC7476 that 
--                is serially shifted in on each clock cycle(SDATA1 and
--                SDATA2). The outputs are the SCLK signal which clocks
--                the PMOD-AD1 board at 12.5 MHz and a chip select 
--                signal (nCS) that enables the ADC7476 chips on the
--                PMOD-AD1 board as well as two 12-bit output 
--                vectors labeled DATA1 and DATA2 which can be used by 
--                any external components. The START is used to tell
--                the component when to start a conversion. After a
--                conversion is done the component activates the DONE
--                signal.
--
--------------------------------------------------------------------------

entity pmodda3 is
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
    start_ad1: in std_logic; 
    DONE     : out std_logic
            );

end pmodda3 ;

architecture DA3 of pmodda3 is

--------------------------------------------------------------------------------
-- Title            : Local signal assignments
--
-- Description      : The following signals will be used to drive the  
--                    processes of this VHDL file.
--
--   current_state : This signal will be the pointer that will point at the
--                   current state of the Finite State Machine of the 
--                   controller.
--   next_state    : This signal will be the pointer that will point at the
--                   current state of the Finite State Machine of the 
--                   controller.
--   temp1         : This is a 16-bit vector that will store the 16-bits of data 
--                   that are serially shifted-in form the  first ADC7476 chip
--                   inside the PMOD-AD1 board.
--   temp2         : This is a 16-bit vector that will store the 16-bits of data 
--                   that are serially shifted-in form the second ADC7476 chip 
--                   inside the PMOD-AD1 board.
--   clk_div       : This will be the divided 12.5 MHz clock signal that will
--                   clock the PMOD-AD1 board
--   clk_counter   : This counter will be used to create a divided clock signal.
--
--   shiftCounter  : This counter will be used to count the shifted data from  
--                   the ADC7476 chip inside the PMOD-AD1 board.
--   enShiftCounter: This signal will be used to enable the counter for the  
--                   shifted data from the ADC7476 chip inside the PMOD-AD1.
--   enParalelLoad : This signal will be used to enable the load the shifted  
--                   data in a register.
--------------------------------------------------------------------------------

type states is (SyncData,
                ShiftIn, 
                SyncDac,
                Dacwait);  
          signal current_state : states;
          signal next_state    : states;
          signal nCSreg        : std_logic;           
          signal inreg         : std_logic_vector(15 downto 0);                
          signal DONEreg       : std_logic;
--          signal nLDACreg       : std_logic;                
          signal clk_div       : std_logic;      
          signal clk_counter   : std_logic_vector(1 downto 0);  
          signal shiftCounter  : std_logic_vector(4 downto 0) := "00000"; 
          signal enLoadData    : std_logic;
          signal enShift       : std_logic;
          signal enShiftreg    : std_logic;
        

begin
        
--------------------------------------------------------------------------------
-- Title          :     clock divider process
--
-- Description    : This is the process that will divide the 100 MHz clock 
--                  down to a clock speed of 25 MHz to drive the chip. 
--------------------------------------------------------------------------------        

        clock_divide : process(rst,clk)
        begin
            if rst = '1' then
                clk_counter <= "00";
            elsif (clk = '1' and clk'event) then
                clk_counter <= clk_counter + '1';
            end if;
        end process;

        clk_div <= clk_counter(1);
        process(clk)
        begin
            if(rising_edge(clk)) then 
            SCLK <=  not clk_counter(1);
            end if;
        end process;

-----------------------------------------------------------------------------------
--
-- Title      : counter
--
-- Description: This is the process were the converted data will be colected and
--              output.When the enShiftCounter is activated, the 16-bits of data  
--              from the ADC7476 chips will be shifted inside the temporary 
--              registers. A 4-bit counter is used to keep shifting the data 
--              inside temp1 and temp2 for 16 clock cycles. When the enParalelLoad
--              signal is generated inside the SyncData state, the converted data 
--              in the temporary shift registers will be placed on the outputs 
--              DATA1 and DATA2. 
--    
-----------------------------------------------------------------------------------    

counter : process(clk_div, enLoadData, enShift)
        begin
            if (clk_div = '1' and clk_div'event) then               
                if (enLoadData = '1') then 
                    inreg <= DATA;
                    shiftCounter <= "00000";
                elsif (enShift = '1') then
                    INDATA <= inreg(15);
                    inreg  <= inreg(14 downto 0)  & 'X';
                    shiftCounter <= shiftCounter + '1';
                end if;
            end if;
        end process;
   
---------------------------------------------------------------------------------
--
-- Title      : Finite State Machine
--
-- Description: This 3 processes represent the FSM that contains three states.
--              The first state is the Idle state in which a temporary registers
--              are assigned the updated value of the input "DATA1" and "DATA2".
--              The next state is the ShiftIn state where the 16-bits of data
--              from each of the ADCS7476 chips are left shifted in the temp1
--              and temp2 shift registers. The third state, SyncData drives the
--              output signal nCS high for 1 clock period maintainig nCS high  
--              also in the Idle state telling the ADCS7476 to mark the end of
--              the conversion.
-- Notes:         The data will change on the lower edge of the clock signal. There 
--                     is also an asynchronous reset that will reset all signals to  
--                     their original state.
--
-----------------------------------------------------------------------------------        
        
-----------------------------------------------------------------------------------
--
-- Title      : SYNC_PROC
--
-- Description: This is the process were the states are changed synchronously. At 
--              reset the current state becomes Idle state.
--    
-----------------------------------------------------------------------------------            
SYNC_PROC: process (clk_div, rst)
   begin
      if (clk_div'event and clk_div = '1') then
         if (rst = '1') then
            current_state <= SyncData;
         else
            current_state <= next_state;
         end if;        
      end if;
   end process;
    
-----------------------------------------------------------------------------------
--
-- Title      : OUTPUT_DECODE
--
-- Description: This is the process were the output signals are generated
--              unsynchronously based on the state only (Moore State Machine).
--    
-----------------------------------------------------------------------------------        
OUTPUT_DECODE: process (current_state)
   begin
      if current_state = SyncData then
            enLoadData <='1';
            enShiftreg <= '0';
            DONEreg <='0';
            nCSreg <='1';
--            nLDACreg <= '1';
--            nCS <= '1';
            nLDAC <= '1';
        elsif current_state = ShiftIn then
            enLoadData <= '0';
            enShiftreg <='1';
            DONEreg <='0';
            nCSreg <='0';
--            nLDACreg <= '1';
--            nCS <= '0';
            nLDAC <= '1';        
        elsif current_state = SyncDac then
            enLoadData <='0';
            enShiftreg <= '0';
            DONEreg <='0';
            nCSreg <='1';
--            nLDACreg <= '0';
--            nCS <= '1';
            nLDAC <= '0';
        elsif current_state = DacWait then
            enLoadData <='0';
            enShiftreg <= '0';
            DONEreg <='1';
            nCSreg <='1';
--            nLDACreg <= '1';
--            nCS <= '1';
            nLDAC <= '0';         
        end if;
   end process;    

        process(clk_div)
        begin
            if(rising_edge(clk_div)) then 
            enShift <= enShiftreg;           
            end if;
        end process;
        process(clk_div)
        begin
            if(falling_edge(clk_div)) then 
            DONE <= DONEreg;
            nCS <=  nCSreg;
            end if;
        end process;        
----------------------------------------------------------------------------------
--
-- Title      : NEXT_STATE_DECODE
--
-- Description: This is the process were the next state logic is generated 
--              depending on the current state and the input signals.
--    
-----------------------------------------------------------------------------------    
    NEXT_STATE_DECODE: process (current_state, START, shiftCounter,start_ad1)
   begin
      next_state <= current_state;  -- default is to stay in current state
      case (current_state) is
         when SyncData =>
            if START = '1' then
               next_state <= ShiftIn;
            end if;
         when ShiftIn =>
            if shiftCounter = "10000" then
               next_state <= SyncDac;
            end if;
         when SyncDac =>
            next_state <= DacWait;
         when DacWait =>
            if start_ad1 = '0' then
                next_state <= SyncData;
            end if;
         when others =>
            next_state <= SyncData;
      end case;      
   end process;


end DA3;