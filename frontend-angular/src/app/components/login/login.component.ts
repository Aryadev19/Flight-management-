import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  isLogin = true;
  email = '';
  password = '';
  name = '';
  phoneNumber = '';
  role = 'PASSENGER';
  error = '';
  loading = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  toggleMode() {
    this.isLogin = !this.isLogin;
    this.error = '';
  }

  onSubmit() {
    this.error = '';
    this.loading = true;

    if (this.isLogin) {
      this.authService.login({ email: this.email, password: this.password })
        .subscribe({
          next: (response) => {
            this.loading = false;
            if (response.role === 'ADMIN') {
              this.router.navigate(['/admin']);
            } else {
              this.router.navigate(['/passenger']);
            }
          },
          error: (error) => {
            this.loading = false;
            this.error = 'Invalid email or password';
          }
        });
    } else {
      this.authService.register({
        email: this.email,
        password: this.password,
        name: this.name,
        role: this.role,
        phoneNumber: this.phoneNumber
      }).subscribe({
        next: (response) => {
          this.loading = false;
          if (response.role === 'ADMIN') {
            this.router.navigate(['/admin']);
          } else {
            this.router.navigate(['/passenger']);
          }
        },
        error: (error) => {
          this.loading = false;
          this.error = error.error?.message || 'Registration failed';
        }
      });
    }
  }
}