----------------FSM--------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    port(
        i_start, done   : in std_logic;
        i_clk, i_rst    : in std_logic;
        
        o_done                : out std_logic;
        o_mem_we,o_mem_en     : out std_logic;
        sel                   : out std_logic;
        en_reg, en_c32, en_cW : out std_logic;
        rst_cW, rst_reg       : out std_logic
    );
end FSM;

architecture FSM_arch of FSM is
    type STATE is (S0, S1, S2, S3);
    signal next_state, curr : STATE;
begin

    state_reg : process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            curr <= S0;
        elsif rising_edge(i_clk) then
            curr <= next_state;
        end if;
    end process;
    
    lambda : process(curr, i_start, done)
    begin
        case curr is
           when S0 => 
                if i_start = '0' then
                    next_state <= S0;
                else
                    next_state <= S1;
                end if;
           when S1 =>
                if i_start = '0' then
                    next_state <= S0;
                elsif(i_start = '1' and done = '0') then
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
           when S2 => 
                next_state <= S3;
           when S3 =>
                next_state <= S0;
        end case;
    end process;
    
    delta : process(curr, i_start, done)
    begin
        case curr is
            when S0 =>
                if i_start = '0' then
                    o_mem_we <= '0';
                    o_mem_en <= '0';
                    o_done   <= '0';
                    sel      <= '0';
                    en_reg   <= '0';
                    en_c32   <= '0';
                    en_cW    <= '0';
                    rst_cW   <= '1';
                    rst_reg  <= '0';
                else
                    o_mem_we <= '0';
                    o_mem_en <= '1';
                    o_done   <= '0';
                    sel      <= '0';
                    en_reg   <= '0';
                    en_c32   <= '0';
                    en_cW    <= '0';
                    rst_cW   <= '0';
                    rst_reg  <= '0';
                end if;
            when S1 =>
                if i_start = '0' then
                    o_mem_we <= '0';
                    o_mem_en <= '0';
                    o_done   <= '0';
                    sel      <= '0';
                    en_reg   <= '0';
                    en_c32   <= '0';
                    en_cW    <= '0';
                    rst_cW   <= '1';
                    rst_reg  <= '0';
                elsif(i_start = '1' and done = '0') then
                    o_mem_we <= '1';
                    o_mem_en <= '1';
                    o_done   <= '0';
                    sel      <= '0';
                    en_reg   <= '1';
                    en_c32   <= '0';
                    en_cW    <= '0';
                    rst_cW   <= '0';
                    rst_reg  <= '0';
                else
                    o_mem_we <= '0';
                    o_mem_en <= '0';
                    o_done   <= '1';
                    sel      <= '0';
                    en_reg   <= '0';
                    en_c32   <= '0';
                    en_cW    <= '0';
                    rst_cW   <= '0';
                    rst_reg  <= '1';
                end if;
            when S2 =>
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_done   <= '0';
                sel      <= '0';
                en_reg   <= '0';
                en_c32   <= '1';
                en_cW    <= '1';
                rst_cW   <= '0';
                rst_reg  <= '0';
            when S3 =>
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_done   <= '0';
                sel      <= '1';
                en_reg   <= '0';
                en_c32   <= '0';
                en_cW    <= '1';
                rst_cW   <= '0';
                rst_reg  <= '0';
        end case;
    end process;
end FSM_arch;


-----------------WORD COUNTER--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count_words is
    port(
        i_add : in std_logic_vector(15 downto 0);
        i_k : in std_logic_vector(9 downto 0);
        en, i_clk, i_rst : in std_logic;
        
        val : out std_logic_vector(10 downto 0);
        o_mem_addr : out std_logic_vector(15 downto 0)
    );
end count_words;

architecture count_words_arch of count_words is
    signal c : unsigned(10 downto 0) := (others => '0');
    signal max : unsigned(10 downto 0);
begin
    max <= unsigned(i_k(9 downto 0) & '0');
    o_mem_addr <= std_logic_vector(unsigned(i_add) + c);
    val <= std_logic_vector(c);
    
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            c <= (others => '0');
        elsif rising_edge(i_clk) and en = '1' then
            if (c < max) then
                c <= c+1;
            end if;
        end if;
    end process;
end count_words_arch;


-------------------REGISTER--------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
    port(
        en, i_rst, i_clk : in std_logic;
        i_mem_data       : in std_logic_vector(7 downto 0);
        
        o_data : out std_logic_vector(7 downto 0);
        rst_c  : out std_logic
    );
end reg;

architecture reg_arch of reg is
begin

    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_data <= (others => '0');
        elsif rising_edge(i_clk) and en = '1' then
            if(i_mem_data /= "00000000") then
                o_data <= i_mem_data;
                rst_c  <= '1';
            else
                rst_c  <= '0';
            end if;
        end if;
    end process;
    
end reg_arch;


---------------------COUNT VALIDITY-------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count_validity is
    port(
        i_rst, i_clk : in std_logic;
        value : in std_logic_vector(7 downto 0);
        en    : in std_logic;
        
        o_data : out std_logic_vector(7 downto 0)
    );
end count_validity;

architecture count_validity_arch of count_validity is
    signal c : unsigned(7 downto 0);
begin
    o_data <= std_logic_vector(c);
    
    process(i_clk, i_rst)  
    begin
        if(i_rst = '1')then
            c <= "00011111";
        elsif rising_edge(i_clk) and en = '1' then
            if(value = "00000000") then
                c <= (others  => '0');
            elsif c > 0 then
                c <= c-1;
            end if;
        end if;   
    end process;
end count_validity_arch;


-----------------------MULTIPLEXER---------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    port(
        reg, count : in std_logic_vector(7 downto 0);
        sel        : in std_logic;
            
        o_mem_data : out std_logic_vector(7 downto 0) 
    );
end mux;

architecture mux_arch of mux is
begin
    o_mem_data <= reg when sel = '0' else
                  count when sel = '1' else
                  (others => '-');
end mux_arch;


--------------------CHECK COUNT-------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checkCount is
    port(
        i_k : in std_logic_vector(9 downto 0);
        c : in std_logic_vector(10 downto 0);
        
        done : out std_logic
    );
end checkCount;

architecture checkCount_arch of checkCount is
begin
    done <= '1' when unsigned(c) >= unsigned(i_k(9 downto 0) & '0') else
            '0';
end checkCount_arch;


-------------------------COMPONENT-----------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is 
    port ( 
        i_clk      : in std_logic; 
        i_rst      : in std_logic; 
        i_start    : in std_logic; 
        i_add      : in std_logic_vector(15 downto 0); 
        i_k        : in std_logic_vector(9 downto 0); 
        o_done     : out std_logic; 
        o_mem_addr : out std_logic_vector(15 downto 0); 
        i_mem_data : in std_logic_vector(7 downto 0); 
        o_mem_data : out std_logic_vector(7 downto 0); 
        o_mem_we   : out std_logic; 
        o_mem_en   : out std_logic 
    ); 
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
    component FSM is
        port(
            i_start, done         : in std_logic;
            i_clk, i_rst          : in std_logic;
            
            o_done                : out std_logic;
            o_mem_we,o_mem_en     : out std_logic;
            sel                   : out std_logic;
            en_reg, en_c32, en_cW : out std_logic;
            rst_cW, rst_reg       : out std_logic
        );
    end component;
    
    component count_words is
        port(
            i_add            : in std_logic_vector(15 downto 0);
            i_k              : in std_logic_vector(9 downto 0);
            en, i_clk, i_rst : in std_logic;
            
            val              : out std_logic_vector(10 downto 0);
            o_mem_addr       : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component reg is
        port(
            en, i_rst, i_clk : in std_logic;
            i_mem_data       : in std_logic_vector(7 downto 0);
            
            o_data           : out std_logic_vector(7 downto 0);
            rst_c            : out std_logic
        );
    end component;
    
    component count_validity is
        port(
            i_rst, i_clk : in std_logic;
            value        : in std_logic_vector(7 downto 0);
            en           : in std_logic;
            
            o_data       : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component mux is
        port(
            reg, count : in std_logic_vector(7 downto 0);
            sel        : in std_logic;
                
            o_mem_data : out std_logic_vector(7 downto 0) 
        );
    end component;
    
    component checkCount is
        port(
            i_k  : in std_logic_vector(9 downto 0);
            c    : in std_logic_vector(10 downto 0);
            
            done : out std_logic
        );
    end component;
    
    signal en_cW, en_c32, en_reg, rst_cW, rst_c32, rst_reg_FSM, rst_reg : std_logic;
    signal done_FSM : std_logic;
    signal sel : std_logic;
    signal reg_mux, count_mux : std_logic_vector(7 downto 0);
    signal val : std_logic_vector(10 downto 0);
begin

    rst_reg <= i_rst or rst_reg_FSM;
    
    controller : FSM port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        done => done_FSM,
        o_done => o_done,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en,
        sel => sel,
        en_reg => en_reg,
        en_c32 => en_c32,
        en_cW => en_cW,
        rst_cW => rst_cW,
        rst_reg => rst_reg_FSM
    );
    
    count_w : count_words port map(
        i_clk => i_clk,
        i_rst => rst_cW,
        i_add => i_add,
        i_k => i_k,
        en => en_cW,
        val => val,
        o_mem_addr => o_mem_addr
    );
    
    regis : reg port map(
        i_clk => i_clk,
        i_rst => rst_reg,
        en => en_reg,
        i_mem_data => i_mem_data,
        o_data => reg_mux,
        rst_c => rst_c32
    );
    
    validity : count_validity port map(
       i_clk => i_clk,
       i_rst => rst_c32,
       en => en_c32,
       value => reg_mux,
       o_data => count_mux 
    );
    
    multiplexer : mux port map(
        reg => reg_mux,
        count => count_mux,
        sel => sel,
        o_mem_data => o_mem_data
    );
    
    check : checkCount port map(
        i_k => i_k,
        c => val,
        done => done_FSM
    );
end project_reti_logiche_arch;
