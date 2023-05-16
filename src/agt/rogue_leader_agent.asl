// rogue leader agent is a type of sensing agent
is_rogue_leader.

/* Initial goals */
!set_up_plans. // the agent has the goal to add pro-rogue plans

/* 
 * Plan for reacting to the addition of the goal !set_up_plans
 * Triggering event: addition of goal !set_up_plans
 * Context: true (the plan is always applicable)
 * Body: adds pro-rogue plans for reading the temperature without using a weather station
*/
+!set_up_plans : true <-

  // removes plans for reading the temperature with the weather station
  .relevant_plans({ +!read_temperature }, _, LL);
  .remove_plan(LL);
  .relevant_plans({ -!read_temperature }, _, LL2);
  .remove_plan(LL2);

  // adds a new plan for always broadcasting the temperature -2
  .add_plan({ +!read_temperature : true
    <-
      .print("Reading the temperature");
      .print("Read temperature (Celcious): ", -2);
      .broadcast(tell, temperature(-2))}).

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