package com.imhsp.common.exception;

import com.imhsp.common.entity.Result;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(Exception.class)
    public Result<String> handleException(Exception e) {
        return Result.error(e.getMessage());
    }
} 