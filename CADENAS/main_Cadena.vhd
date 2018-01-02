-----------------------------------------------------------------------------------//
-- Nom du projet 		    : CADENAS V0.2
-- Nom du fichier 		    : Main_Cadena.vhd
-- Date de création 	    : 19.11.2016
-- Date de modification     : 02.01.2018
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation, réaliser Projet CANEDANS 
--							  V0.3 voir données Test 2 semestre 1 
--
-- Remarques 			    : lien
-- 							  
----------------------------------------------------------------------------------//

-- déclaration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
			
-- déclaration de l'entité (Entrées / Sorties) --
entity CADENA_V2 is
	port(
		------------
		-- entrée --
		------------ 
		-- logique --  
		SW_13, SW_14, SW_9 	: in std_logic; 					-- switch S11, S13, S14 
		-- bus --
		BUS_SW			 	: in std_logic_vector(0 to 3);		-- représente les switches S1 à S4 		
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		LED_D12, LED_D13	: out std_logic; 
		SEGMENTS_1 			: out std_logic_vector(6 downto 0); 	-- Affichage 7Seg  			-GFEDCBA-
		SEGMENTS_2 			: out std_logic_vector(6 downto 0) 		-- Affichage 7Seg 			-GFEDCBA-
	); 
END CADENA_V2; 


-- déclaration de l'architecture --
architecture COMPORTEMENT_GENERAL_CADENA of CADENA_V2 is

	----------------------
	-- signaux internes -- 
	----------------------
	signal code_interne 	: std_logic_vector(0 to 3) := "0000";  	-- code de départ 
	signal bus_sw_interne	: std_logic_vector(0 to 1); 			-- regroupe les switch S13 et S14 


	begin 

	------------------------------------
	-- lecture swicthes S11, S13, S14 --
	------------------------------------
	bus_sw_interne <= (SW_13, SW_14); 
	
	COMPAR: process(bus_sw_interne)
		begin 
		
			case bus_sw_interne is    
				-- première condition du tableau --
				when "00" => 
					-- Affichage -- 
								 --GFEDCBA--
					SEGMENTS_1 <= "0111111";	-- affiche '-' 
					SEGMENTS_2 <= "0111111";	-- affiche '-'
					
					-- Leds -- 
					LED_D12 <= '1'; 	-- led éteinte 
					LED_D13 <= '1'; 	-- les éteinte
					
				
				-- deuxième condition du tableau -- 	
				when "01" => 
					-- test si le switch S9 en enfoncé -- 
					if SW_9 = '0' then 
						-- Affichage --
						             --GFEDCBA--
						SEGMENTS_1 <= "0000000";	-- affiche '8'
						SEGMENTS_2 <= "0000000"; 	-- affiche '8'
						
						-- Leds --
						LED_D12 <= '0'; 	-- led allumée  
						LED_D13 <= '0'; 	-- les allumée  
						
						-- mémorisation nouveau code -- 
						code_interne <= BUS_SW; 

					end if; 
				
				-- troisieme condition du tableau -- 
				when "11" =>
					-- test entre le code interne et les switches -- 
					if code_interne = BUS_SW then 
						-- affichage --
									 --GFEDCBA--
						SEGMENTS_1 <= "1000000";	-- affiche 'O' 
						SEGMENTS_2 <= "0001100";	-- affiche 'P' 
						
						-- Leds --
						LED_D12 <= '0'; 	-- led allumée  
						LED_D13 <= '1'; 	-- led éteinte 
					else
						-- Affichage -- 
									 --GFEDCBA--
						SEGMENTS_1 <= "1000110";	-- affiche 'C'
						SEGMENTS_2 <= "1000111"; 	-- affiche 'L'
						
						-- Leds --
						LED_D12 <= '1'; 	-- led éteinte  
						LED_D13 <= '0'; 	-- les allumée  
			
					end if; 
				-- pour tout autre condition 
				when others =>
				                 --GFEDCBA--
					SEGMENTS_1 <= "1111111"; 				-- tous les segment sont éteint
					SEGMENTS_2 <= "1111111"; 				-- tous les segment sont éteint
			end case; 
	end process;  

end COMPORTEMENT_GENERAL_CADENA; 
