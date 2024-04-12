package com.everypet.config;

import com.everypet.auth.jwt.data.repository.RefreshTokenRepository;
import com.everypet.auth.jwt.filter.CustomLogoutFilter;
import com.everypet.auth.jwt.filter.JWTFilter;
import com.everypet.auth.jwt.filter.LoginFilter;
import com.everypet.auth.oauth2.handler.CustomSuccessHandler;
import com.everypet.auth.oauth2.config.CustomClientRegistrationRepo;
import com.everypet.auth.oauth2.service.CustomOAuth2UserService;
import com.everypet.auth.util.CookieManager;
import com.everypet.auth.util.JWTManager;
import com.everypet.member.service.UserLoginFailHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import javax.servlet.http.HttpServletRequest;
import java.util.Collections;

@Configuration
@EnableWebSecurity
@ComponentScan(basePackages = "com.everypet.auth.*")
@RequiredArgsConstructor
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final AuthenticationConfiguration authenticationConfiguration;
    private final JWTManager jwtManager;
    private final CustomOAuth2UserService customOAuth2UserService;
    private final CustomClientRegistrationRepo customClientRegistrationRepo;
    private final CustomSuccessHandler customSuccessHandler;
    private final JWTFilter jwtFilter;
    private final RefreshTokenRepository refreshTokenRepository;
    private final CookieManager cookieManager;

    @Bean
    public UserLoginFailHandler userLoginFailHandler() {
        return new UserLoginFailHandler();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {

        // 로그인 필터 추가
        LoginFilter loginFilter = new LoginFilter(authenticationManager(authenticationConfiguration), jwtManager, cookieManager);
        loginFilter.setFilterProcessesUrl("/signin"); // 실제 로그인을 처리할 URL을 입력

        http
                .authorizeRequests() // 요청에 대한 보안 설정
                    .antMatchers("/resources/**").permitAll()
                    .antMatchers("/signin").anonymous()
                    .antMatchers("/signup").anonymous()
                    .antMatchers("/").permitAll()
                    .antMatchers("/admin").hasRole("ADMIN")
                    .antMatchers("/reissue").permitAll()
                    .anyRequest().permitAll();

        http // 필터 위치
                .addFilterBefore(jwtFilter, LoginFilter.class)
                .addFilterBefore(new CustomLogoutFilter(jwtManager, refreshTokenRepository), LogoutFilter.class)
                .addFilterAt(new LoginFilter(authenticationManager(authenticationConfiguration), jwtManager, cookieManager),
                            UsernamePasswordAuthenticationFilter.class)
                .addFilterAt(loginFilter, UsernamePasswordAuthenticationFilter.class);

        http // disable 설정
                .httpBasic().disable()  //http basic 인증 방식 disable
                .formLogin().disable()
                .csrf().disable()
                    /*.loginPage("/")
                    .loginProcessingUrl("/signin")
                    .usernameParameter("member_id")
                    .passwordParameter("member_pwd")
                    .defaultSuccessUrl("/success")
                    .failureHandler(userLoginFailHandler())
                    .and */
                .logout().disable();
                    /*.logoutUrl("/logout")
                    .logoutSuccessUrl("/")
                    .invalidateHttpSession(true)
                    .deleteCookies("JSESSIONID")
                    .and()*/
        http
                .exceptionHandling() // 예외 처리
                    .accessDeniedPage("/");
        http
                .sessionManagement() // 세션 관리
                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS);
        http // cors 설정
                .cors((corsCustomizer -> corsCustomizer.configurationSource(new CorsConfigurationSource() {

                    @Override
                    public CorsConfiguration getCorsConfiguration(HttpServletRequest request) {

                        CorsConfiguration configuration = new CorsConfiguration();

                        configuration.setAllowedOrigins(Collections.singletonList("http://localhost:3000"));
                        configuration.setAllowedMethods(Collections.singletonList("*"));
                        configuration.setAllowCredentials(true);
                        configuration.setAllowedHeaders(Collections.singletonList("*"));
                        configuration.setMaxAge(3600L);

                        configuration.setExposedHeaders(Collections.singletonList("Authorization"));

                        return configuration;
                    }
                })));

        // oauth2
        http
                .oauth2Login((oauth2) -> oauth2
                        .userInfoEndpoint((userInfoEndpointConfig -> userInfoEndpointConfig.userService(customOAuth2UserService)))
                        .clientRegistrationRepository(customClientRegistrationRepo.clientRegistrationRepository())
                        .successHandler(customSuccessHandler)
                );

    }
}