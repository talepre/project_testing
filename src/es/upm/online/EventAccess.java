package es.upm.online;

import java.util.regex.Pattern;
import java.util.concurrent.TimeUnit;

import junit.framework.TestCase;
import org.junit.*;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;
import org.openqa.selenium.*;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Select;

public class EventAccess extends TestCase {
  private WebDriver driver;
  private String baseUrl;
  private boolean acceptNextAlert = true;
  private StringBuffer verificationErrors = new StringBuffer();

  @Before
  public void setUp() throws Exception {
    driver = new FirefoxDriver();
    baseUrl = "https://online.ntnu.no/";
    driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
  }

  @Test
  public void testEventaccess() throws Exception {
    driver.get(baseUrl + "/events/211/julebord/");
    assertTrue(isElementPresent(By.className("alert-danger")));
    driver.findElement(By.xpath("//nav[@id='mainnav']/div/ul[3]/li/a")).click();
    driver.findElement(By.id("id_username")).clear();
    driver.findElement(By.id("id_username")).sendKeys("talep");
    driver.findElement(By.id("id_password")).clear();
    driver.findElement(By.id("id_password")).sendKeys("OnlineErlang");
    driver.findElement(By.cssSelector("button.btn.btn-primary")).click();
    driver.get(baseUrl + "/events/211/julebord/");
    assertEquals("Julebord - Online", driver.getTitle());
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
