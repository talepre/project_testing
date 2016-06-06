package es.upm.online;

import junit.framework.Test;
import junit.framework.TestSuite;

public class TestOnlineNtnu {
    public static Test suite() {
        TestSuite suite = new TestSuite();
        suite.addTestSuite(FilterArticles.class);
        suite.addTestSuite(ExportEvents.class);
        suite.addTestSuite(WikiAccess.class);
        suite.addTestSuite(DashboardAccess.class);
        suite.addTestSuite(StatusEvent.class);
        suite.addTestSuite(EventAccess.class);
        return suite;
        }

    public static void main(String[] args) {
    junit.textui.TestRunner.run(suite());
  }
}
