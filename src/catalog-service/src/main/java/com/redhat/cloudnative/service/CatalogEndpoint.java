package com.redhat.cloudnative.service;

import java.util.List;

import com.redhat.cloudnative.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import io.micrometer.core.instrument.Metrics;


@Controller
@RequestMapping("/api")
public class CatalogEndpoint {

    @Autowired
    private CatalogService catalogService;

    @ResponseBody
    @GetMapping("/products")
    @CrossOrigin
    public ResponseEntity<List<Product>> readAll() {
        Metrics.counter("api.catalog.readall.total").increment(1.0);
        return new ResponseEntity<List<Product>>(catalogService.readAll(),HttpStatus.OK);
    }

    @ResponseBody
    @GetMapping("/product/{id}")
    @CrossOrigin
    public ResponseEntity<Product> read(@PathVariable("id") String id) {
        Metrics.counter("api.catalog.read.total", "api", "inventory", "method", "GET", "endpoint", "/product/" + id).increment();
        return new ResponseEntity<Product>(catalogService.read(id),HttpStatus.OK);
    }

}
