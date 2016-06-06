package es.upm;

import java.util.regex.Pattern;
import java.util.concurrent.TimeUnit;
import org.junit.*;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;
import org.openqa.selenium.*;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Select;

public class filterdancestyles {
    private WebDriver driver;
    private String baseUrl;
    private boolean acceptNextAlert = true;
    private StringBuffer verificationErrors = new StringBuffer();

    @Before
    public void setUp() throws Exception {
        driver = new FirefoxDriver();
        baseUrl = "https://ntnuidans.no";
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

    @Test
    public void testFilterdancestyles() throws Exception {
        driver.get(baseUrl + "/nyheter/");
        driver.findElement(By.linkText("Filtrer")).click();
        driver.findElement(By.id("dancestyle_10")).click();
        driver.findElement(By.id("dancestyle_17")).click();
        driver.findElement(By.id("dancestyle_15")).click();
        driver.findElement(By.cssSelector("input.primary-button")).click();
        //driver.findElement(By.linkText("1. plass til NTNUI Dans")).click();
        assertTrue(isElementPresent(By.linkText("1. plass til NTNUI Dans")));
        assertFalse(isElementPresent(By.linkText("Poledanceseksjonen søker ny leder!")));
    }

    @After
    public void tearDown() throws Exception {
        driver.quit();
        String verificationErrorString = verificationErrors.toString();
        if (!"".equals(verificationErrorString)) {
            fail(verificationErrorString);
        }
    }

    private boolean isElementPresent(By by) {
        try {
            driver.findElement(by);
            return true;
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    private boolean isAlertPresent() {
        try {
            driver.switchTo().alert();
            return true;
        } catch (NoAlertPresentException e) {
            return false;
        }
    }

    private String closeAlertAndGetItsText() {
        try {
          Alert alert = driver.switchTo().alert();
          String alertText = alert.getText();
          if (acceptNextAlert) {
              alert.accept();
          } else {
              alert.dismiss();
          }
          return alertText;
        } finally {
          acceptNextAlert = true;
        }
    }
}
