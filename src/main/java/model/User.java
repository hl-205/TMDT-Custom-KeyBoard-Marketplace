package model;

import java.sql.Date;

public class User {
    private int id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String password;
    private String gender;
    private Date dob;
    private String avatarText;
    private String role;
    private int points;
    private boolean isVerified;
    private String status;

    public User() {}

    public User(int id, String firstName, String lastName, String email, String phone,
                String password, String avatarText, String role, int points) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.avatarText = avatarText;
        this.role = role;
        this.points = points;
    }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }

    public String getShortDisplayName() {
        if (lastName != null && !lastName.isEmpty() && firstName != null && !firstName.isEmpty()) {
            return lastName + " " + firstName.charAt(0) + ".";
        }
        return getFullName();
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Date getDob() { return dob; }
    public void setDob(Date dob) { this.dob = dob; }

    public String getAvatarText() { return avatarText; }
    public void setAvatarText(String avatarText) { this.avatarText = avatarText; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public boolean isVerified() { return isVerified; }
    public void setVerified(boolean verified) { isVerified = verified; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}