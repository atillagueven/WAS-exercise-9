// sensing agent

/* Initial beliefs and rules */

// infers whether there is a mission for which goal G has to be achieved by an agent with role R
role_goal(R,G) :- role_mission(R,_,M) & mission_goal(M,G).

// infers whether there the agent has a plan that is relevant for goal G
has_plan_for(G) :- .relevant_plans({+!G},LP) & LP \== [].

// infers whether there is no goal associated with role R for which the agent does not have a relevant plan
i_have_plans_for(R) :- not (role_goal(R,G) & not has_plan_for(G)).

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("Reading the temperature");
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Read temperature (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

+send_witness_rep : true <-
		.findall([X, Y], temperature(X)[source(Y)], TempAgValues);
		.findall(K, .member([K, _], TempAgValues), TempValues);
		.findall(K, .member([_, K], TempAgValues), AgValues);
    for ( .range(I, 0, (.length(TempValues) - 1)) ) {
    	.nth(I, AgValues, Ag);
        .my_name(Me);
        is_rogue_agent(Ag, X);
        .nth(I, TempValues, Temp);
        if(not X) {
            .print("Sent: ", 1, " for agent: ", Ag);
          		.send(acting_agent, tell, witness_reputation(Me, Ag, temperature(Temp)[source(Ag)], 1));
        } else {
            .print("Sent: ", -1, " for agent: ", Ag);
          		.send(acting_agent, tell, witness_reputation(Me, Ag, temperature(Temp)[source(Ag)], -1));
        }
    }.


/* 
 * Plan for reacting to the addition of the belief organization_deployed(OrgName)
 * Triggering event: addition of belief organization_deployed(OrgName)
 * Context: true (the plan is always applicable)
 * Body: joins the workspace and the organization named OrgName, and creates the goal of adopting relevant roles
*/
@organization_deployed_plan
+organization_deployed(OrgName) : true <- 
	.print("Notified about organization deployment of ", OrgName);

	// joins the workspace
	joinWorkspace(OrgName, _);

	// looks up for, and focuses on the OrgArtifact that represents the organization
	lookupArtifact(OrgName, OrgId);
	focus(OrgId);

	// creates the goal for adopting relevant roles
	!adopt_relevant_roles.

/* 
 * Plan for reacting to the addition of goal !adopt_relevant_roles
 * Triggering event: addition of goal !adopt_relevant_roles
 * Context: true (the plan is always applicable)
 * Body: reasons on the organization specification and adopts all relevant roles
*/
@adopt_relevant_roles_plan
+!adopt_relevant_roles : true <-

	// finds all relevant roles
	.findall(Role, role(Role, Super) & i_have_plans_for(Role), RelevantRoles);
	.print("Inferred that I have plans for the roles: ", RelevantRoles);

	// adopts each role in the list RelevantRoles (could have also been implemented recursively)
	for (.member(Role, RelevantRoles)) {
		.print("Adopting the role of ", Role);
        adoptRole(Role);
    }.

/* 
 * Plan for reacting to the addition of the certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating)
 * Triggering event: addition of belief certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating)
 * Context: true (the plan is always applicable)
 * Body: prints new certified reputation rating (relevant from Task 3 and on)
*/
+certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating): true <-
	.print("Certified Reputation Rating: (", CertificationAgent, ", ", SourceAgent, ", ", MessageContent, ", ", CRRating, ")").

+send_certificate[source(Src)] : certified_reputation(CertificationAgent, TargetAgent, MessageContent, CRRating) <-
	.print("Sending certificate to ", Src);
	.send(Src, tell, certified_reputation(CertificationAgent, TargetAgent, MessageContent, CRRating)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }