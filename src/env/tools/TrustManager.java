package tools;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import cartago.*;

public class TrustManager extends Artifact {

  private HashMap<String, TrustObject> trustMap = new HashMap<>();

  @OPERATION
  public void initialize_average_rating(Object sourceAgent, Object[] trustRatings, OpFeedbackParam<Double> avg) {
    var agentName = String.valueOf(sourceAgent.toString());
    var list = Arrays.stream(trustRatings)
        .map(Object::toString)
        .map(Double::valueOf)
        .collect(Collectors.toList());
    var averageTrust = calcAverage(list);
    var trustObject = new TrustObject(averageTrust);
    trustMap.put(agentName, trustObject);
    avg.set(averageTrust);
  }

  @OPERATION
  public void add_certified_reputation(Object sourceAgent, Object crRating) {
    var agentName = String.valueOf(sourceAgent.toString());
    var rating = Double.valueOf(crRating.toString());
    TrustObject trustObject = trustMap.get(agentName);
    trustObject.setCertifiedTrust(rating);
  }

  @OPERATION
  public void add_witness_reputation(Object sourceAgent, Object wrRating) {
    var agentName = String.valueOf(sourceAgent.toString());
    var rating = Double.valueOf(wrRating.toString());
    TrustObject trustObject = trustMap.get(agentName);
    List<Double> witnessTrustList = trustObject.getWitnessTrustList();
    try {
      synchronized (this) {
        witnessTrustList.add(rating);
      } 
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  @OPERATION
  public void get_most_trusted(OpFeedbackParam<String> agentName, OpFeedbackParam<Double> rating) {
    var max = 0d;
    String current = "";
    for (var entry : trustMap.entrySet()) {
      TrustObject value = entry.getValue();
      var itAvg = value.getAverageTrust();
      var crRating = value.getCertifiedTrust();
      var wrAvg = calcAverage(value.getWitnessTrustList());
      var total = 0.33 * itAvg + 0.33 * crRating + 0.33 * wrAvg;
      value.setTotalTrustRating(total);
      if (total > max) {
        max = total;
        current = entry.getKey();
      }
    }
    agentName.set(current);
    rating.set(max);
    trustMap.entrySet().forEach(e -> System.out.println("Agent: " + e.getKey() + " Trust Value: " + e.getValue().getTotalTrustRating()));
  }

  private Double calcAverage(List<Double> list) {
    return list.stream()
        .mapToDouble(Double::doubleValue)
        .average()
        .getAsDouble();
  }

  @OPERATION
  public void equals(Object sourceAgent, Object other, OpFeedbackParam<Boolean> isEqual) {
    var agentName = String.valueOf(sourceAgent.toString());
    var otherAgentName = String.valueOf(other.toString());
    isEqual.set(agentName.equals(otherAgentName));
  }

  @OPERATION
  public void is_rogue_agent(Object agent, OpFeedbackParam<Boolean> isEqual) {
    var agentName = String.valueOf(agent.toString());
    String[] split = agentName.split("_");
    int parseInt = Integer.parseInt(split[2]);
    isEqual.set(parseInt > 4);
  }

  private static class TrustObject {
    private double averageTrust;
    private double certifiedTrust;
    private List<Double> witnessTrustList;
    private Double totalTrustRating;

    public TrustObject(double averageTrust) {
      this.averageTrust = averageTrust;
      this.certifiedTrust = 0d;
      this.witnessTrustList = Collections.synchronizedList(new ArrayList<>());
    }

    public double getAverageTrust() {
      return averageTrust;
    }

    public double getCertifiedTrust() {
      return certifiedTrust;
    }

    public void setCertifiedTrust(double certifiedTrust) {
      this.certifiedTrust = certifiedTrust;
    }

    public List<Double> getWitnessTrustList() {
      return witnessTrustList;
    }

    public Double getTotalTrustRating() {
      return totalTrustRating;
    }

    public void setTotalTrustRating(Double totalTrustRating) {
      this.totalTrustRating = totalTrustRating;
    }
  }
}