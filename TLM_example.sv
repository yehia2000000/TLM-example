/******************************************TLM example **********************************************************/

class packet extends uvm_object ;
  `uvm_object_utils(packet)
  rand int x ; 
  
  
  constraint constr {

    x inside {[0:10]}; 
  }
  
  function new (string name = "packet" );
    super.new(name);
  endfunction 
  
  
endclass 

class sub_componentB extends uvm_component; 
  `uvm_component_utils(sub_componentB) ; 
  uvm_blocking_get_port #(packet) m_get_portB; 
    packet pkt; 
  
  function new (string name ="packet" , uvm_component parent = null ); 
    super.new(name , parent); 
  endfunction 
  
  function void build_phase (uvm_phase phase);
    m_get_portB = new("m_get_portB",this); 
    
  endfunction 
  
  function void connect_phase (uvm_phase phase);
    
    
  endfunction 
  
  task run_phase (uvm_phase phase); 
    repeat (20)begin 
     
     m_get_portB.get(pkt);
    $display ("the x value is : %0d", pkt.x) ; 
    end
  endtask 
  
  
  
endclass


class componentB extends uvm_component; 
  `uvm_component_utils(componentB) 
  uvm_blocking_put_export #(packet) m_put_exportB; 
  uvm_tlm_fifo #(packet) fifo_b ; 
  sub_componentB subcomb ; 
  

  function new(string name = "componentB" , uvm_component parent = null); 
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase); 
    m_put_exportB = new("m_put_exportB", this);
    subcomb = sub_componentB :: type_id ::create ("subcomb",this);
    
    fifo_b = new("fifo_b",this ,3);
    
  endfunction 
  
  function void connect_phase (uvm_phase phase); 
    m_put_exportB.connect(fifo_b.put_export);	
    subcomb.m_get_portB.connect (fifo_b.get_export); 
  endfunction 
  
  task run_phase (uvm_phase phase ) ; 

   
    
  endtask 
  
endclass

class sub_componentA1 extends uvm_component ; 
  `uvm_component_utils (sub_componentA1)
  uvm_blocking_put_port#(packet) m_put_port_subA1 ; 
  packet pkt ; 
  function new (string name = "sub_componentA1" , uvm_component parent = null ); 
    super.new(name , parent);
    
  endfunction 
  
  function void build_phase (uvm_phase phase);
    m_put_port_subA1 = new ("m_put_port_subA1" ,this) ; 
    
  endfunction 
  
  function void connect_phase (uvm_phase phase );
    
  endfunction 
  
  task run_phase (uvm_phase phase ); 
    pkt = packet::type_id ::create ("pkt"); 
    repeat (20)begin  
      pkt.randomize(); 
      m_put_port_subA1.put(pkt);
    end
  endtask
  
  
endclass

class sub_componentA2 extends uvm_component ; 
  `uvm_component_utils (sub_componentA2)
  uvm_blocking_get_port #(packet) m_get_port_subA2 ; 
  uvm_blocking_put_port #(packet) m_put_port_subA2 ; 
  packet pkt ; 
  
  function new (string name = "sub_componentA2" , uvm_component parent = null ); 
    super.new(name , parent);
    
  endfunction 
  
  function void build_phase (uvm_phase phase);
    
    m_get_port_subA2 = new("m_get_port_subA2" ,this); 
    m_put_port_subA2 =new("m_put_port_subA2" ,this);
    
  endfunction 
  
  function void connect_phase (uvm_phase phase );
    
  endfunction 
  
  task run_phase (uvm_phase phase ); 
    repeat (20)begin 
     m_get_port_subA2.get(pkt);
      m_put_port_subA2.put(pkt); 
    end
  endtask
  
  
endclass





class componentA extends uvm_component; 
  `uvm_component_utils(componentA) 
  sub_componentA2 subCompA2 ; 
  sub_componentA1 subCompA1 ; 
  uvm_tlm_fifo#(packet)fifo_A;
  uvm_blocking_put_port#(packet) m_put_portA;

  function new(string name = "componentA" , uvm_component parent = null); 
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    subCompA1 =sub_componentA1 :: type_id ::create ("subCompA1",this) ;
    subCompA2 = sub_componentA2::type_id ::create ("subCompA2",this);
    m_put_portA = new ("m_put_portA",this);
    fifo_A = new("fifo_A" ,this ,3) ; 
  endfunction 
  
  function void connect_phase (uvm_phase phase); 
    subCompA1.m_put_port_subA1.connect(fifo_A.put_export);
    subCompA2.m_get_port_subA2.connect (fifo_A.get_export);
    subCompA2.m_put_port_subA2.connect (m_put_portA);
  endfunction 
  
  task run_phase (uvm_phase phase ) ; 
  
  endtask 
  
endclass


//************ *********************environment ****************************************************/

class my_env extends uvm_env ; 
  `uvm_component_utils(my_env) 
  
  componentA compA ; 
  componentB compB ;
  
  function new (string name = "my_env" , uvm_component phase);
    super.new(name,phase); 
  endfunction 
  
  function void build_phase (uvm_phase phase); 
    compA= componentA :: type_id ::create ("compA",this); 
    compB= componentB :: type_id :: create ("compB",this);   
  endfunction 
  
  function void connect_phase (uvm_phase phase ); 
    compA.m_put_portA.connect(compB.m_put_exportB);
    
  endfunction 
  
  task run_phase (uvm_phase phase ); 
    
    
  endtask 
  
endclass

//*********************************testbench****************************************************/
module test; 
  
  initial begin 
    run_test("my_env");
    
  end
  
endmodule