library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity lab_7 is
port( clk : in std_logic;
          input : in std_logic_vector(3 downto 0);
--          mode : in std_logic;
          sdo : in std_logic;
          cs : out std_logic;
          sck : out std_logic;          
          led : out std_logic_vector(15 downto 0);
          seg : out std_logic_vector(6 downto 0);
          an : out std_logic_vector(3 downto 0) := "1110");
end lab_7;

architecture Behavioral of lab_7 is
    signal clk1Hz : std_logic;
    signal clk2MHz : std_logic;
    signal clk1KHz : std_logic; 
    signal chip_select : std_logic := '1';
    signal serial_clk : std_logic;
    signal module_output : std_logic_vector(3 downto 0) := "0000";
--    signal mux_output: std_logic_vector(3 downto 0);
    signal temp1, temp2, temp3: integer:=0;
    signal N1 : integer := 50000000;
    signal N2 : integer := 25;
    signal N3 : integer := 50000;
--    signal up_down : integer := 0 ;
    signal temp_count : integer := 0;
    signal counter : integer :=0;
    signal clk_counter : integer :=0;
    
        
           
    begin
         
        
  --  1 Hz Clock generation   
   --1 KHz Clock generation 
        process(clk)      
            begin  
            if(clk'EVENT and clk='1') then
                temp1 <= temp1+1;
                temp2 <= temp2+1;
                temp3 <= temp3+1;
                if(temp1 = N1) then
                    clk1Hz <= not clk1Hz;
                    temp1 <= 0;
                end if;
                if(temp2 = N2) then
                    clk2MHz <= not clk2MHz;
                    temp2<=0;
                end if;
                if(temp3 = N3) then
                    clk1KHz <= not clk1KHz;
                    temp3 <= 0;
                end if;
               
                
            end if;                
        end process;
        

        
         -- SPI Communication
         process(clk1Hz, clk2MHz) 
            begin
                if(clk1Hz'EVENT and clk1Hz='1') then
                    chip_select <= '0';
                    
                    temp_count <= 0;
                end if;
                if(clk2MHz'EVENT and clk2MHz='1' and chip_select = '0') then
                   temp_count <= temp_count+1;
                end if; 
                if(temp_count =16) then
                    chip_select <= '1';
                
                        temp_count <= 0;
                    end if;
  
          end process;
          
          process(chip_select) 
            begin
                cs <= chip_select;
          end process;
          
          process(chip_select, clk2MHz)
            begin          
                
               sck <= chip_select or clk2MHz;
           end process;              
           
         process(clk2MHz, chip_select, sdo)
            begin
                                               
                if(clk2MHz'EVENT and clk2MHz='1') then        
                    if(chip_select = '0') then
                            
                        clk_counter <= clk_counter+1;
                        if(clk_counter = 3) then
                            module_output(3) <= sdo;             
                        elsif(clk_counter = 4) then
                            module_output(2) <= sdo;
                        elsif(clk_counter = 5) then
                            module_output(1) <= sdo;
                        elsif(clk_counter = 6) then
                            module_output(0) <= sdo;    
                        end if;
                   else 
                        clk_counter <= 0;
                   end if;
               end if;
        end process;                                         
                    
                    
         
--         --Mux 
--          process(count_output, input, mode)
--            begin     
--                if(mode='0') then
--                    mux_output <= count_output;
--                else
--                    mux_output <= input;
--                end if;
--          end process;  
                        
          
          -- Seven segment display

            process(module_output)
                begin
                  case module_output is
                    when "0000" => seg<="1000000";
                    when "0001" => seg<="1111001";
                    when "0010" => seg<="0100100";
                    when "0011" => seg<="0110000";
                    when "0100" => seg<="0011001";
                    when "0101" => seg<="0010010";
                    when "0110" => seg<="0000010";
                    when "0111" => seg<="1111000";
                    when "1000" => seg<="0000000";
                    when "1001" => seg<="0010000";
                    when "1010" => seg<="0001000";
                    when "1011" => seg<="0000011";
                    when "1100" => seg<="1000110";
                    when "1101" => seg<="0100001";
                    when "1110" => seg<="0000110";
                    when others => seg<="0001110";
                    end case;
              end process;


                              
                    

            --PWM   
            process(module_output, clk1KHz)  
              begin
                 if (clk1KHz='1' AND clk1KHz'EVENT) then
                    counter <= counter+1;
                    if(counter = 17) then
                        counter <= 1;
                    end if;
                   end if;
                 if(counter <= to_integer(unsigned(module_output)) ) then
                    led <= "1111111111111111";
                 else
                    led <= "0000000000000000";
                 end if;
                 
                    
              end process;
end architecture Behavioral;