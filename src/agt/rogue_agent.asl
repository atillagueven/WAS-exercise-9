// rogue agent is a type of sensing agent

/* Initial beliefs and rules */
// initially, the agent believes that it hasn't received any temperature readings
received_readings([]).

/* Initial goals */
!set_up_plans. // the agent has the goal to add pro-rogue plans

/* 
 * Plan for reacting to the addition of the goal !set_up_plans
 * Triggering event: addition of goal !set_up_plans
 * Context: true (the plan is always applicable)
 * Body: adds pro-rogue plans for reading the temperature without using a weather station
*/
+!set_up_plans : true
<-
  // removes plans for reading the temperature with the weather station
  .relevant_plans({ +!read_temperature }, _, LL);
  .remove_plan(LL);
  .relevant_plans({ -!read_temperature }, _, LL2);
  .remove_plan(LL2);

  // Task 2
  //hardcoding sensing agent
  .add_plan({ +!read_temperature : temperature(Temp)[source(sensing_agent_9)]
    <-
    .print("Follow the leader! Temp: ", Temp);
    .broadcast(tell, temperature(Temp)) });

  // waiting loop 
  .add_plan({ +!read_temperature : true
    <-
    .wait(2000);
    !read_temperature }).
    
  // .add_plan({
  //   +sendCertificate[source(Src)] : true
  //   <-
  //     .print("Sending fake certificate to ", Src);
  //     .send(Src, tell, certified_reference(rating(sensing_agent_9, certification_agent, quality, temperature(10), 1.0), signedBy(certification_agent)));
  // }).

+send_witness_rep : true <-
      .findall([X, Y], temperature(X)[source(Y)], TempAgValues);
      .findall(K, .member([K, _], TempAgValues), TempValues);
      .findall(K, .member([_, K], TempAgValues), AgValues);
    for ( .range(I, 0, (.length(TempValues) - 1)) ) {
    	.nth(I, AgValues, Ag);
      .my_name(Me);
      is_rogue_agent(Ag, X);
      .nth(I, TempValues, Temp);
      if(X) {
        .print("Sent: ", 1, " for agent: ", Ag);
          .send(acting_agent, tell, witness_reputation(Me, Ag, temperature(Temp)[source(Ag)], 1));
      } else {
        .print("Sent: ", -1, " for agent: ", Ag);
          .send(acting_agent, tell, witness_reputation(Me, Ag, temperature(Temp)[source(Ag)], -1));
      }
    }.

{ include("sensing_agent.asl")}