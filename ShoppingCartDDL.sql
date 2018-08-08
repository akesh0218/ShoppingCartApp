{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf600
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 drop table orders;\
drop table ordering_items;\
drop table shopping_cart;\
drop table customer;\
drop table product;\
drop sequence shopping_cart_seq;\
drop sequence order_items;\
drop sequence orders_seq;\
\
create sequence shopping_cart_seq start with 1 increment by 1;\
create sequence order_items start with 1 increment by 1;\
create sequence orders_seq start with 1 increment by 1;\
\
create table product (\
product_id number(5) primary key,\
product_name varchar2(20) not null,\
quantity_on_hand number(5),\
quantity_sold number(5),\
product_price decimal(5,2) not null,\
product_restock number(1)\
);\
\
create table customer (\
customer_id number(5) primary key,\
customer_name varchar2(30) not null,\
customer_username varchar2(20),\
credit_limit number(5) not null,\
pay_period number(5)\
);\
\
\
create table shopping_cart (\
cart_id number(5) primary key,\
cart_customer number(5) references customer(customer_id),\
creation_date timestamp(2) not null,\
close_date timestamp(2)\
);\
\
create table ordering_items (\
ordering_items_id number(5) primary key,\
shoppingcart_id number(5) references shopping_cart(cart_id),\
product_id number(5) references product(product_id),\
product_quantity number(5) not null\
);\
\
create table orders (\
order_id number(5) primary key,\
shoppingcart_id number(5) references shopping_cart(cart_id),\
ordercustomer_id number(5) references customer(customer_id),\
order_status varchar2(20) not null,\
order_date timestamp(2),\
ship_date timestamp(2)\
);\
\
insert into customer values(00001, 'Azim Keshwani', 'keshwani', 00010, 00000);\
insert into customer values(00002, 'Hyung Jin Moon', 'moonhc', 10000, 00000);\
insert into customer values(00003, 'McKenzie Cole', 'colemn', 10000, 00000);\
insert into customer values(00004, 'Nathaniel Campbell', 'campbeng', 10000, 00000);\
insert into customer values(00005, 'Rachel Thompson', 'thompsrv', 10000, 00000);\
insert into customer values(00006, 'Vikesh Martinez', 'mahbooba', 10000, 00000);\
insert into customer values(00007, 'John Spang', 'spang', 10000, 00000);\
\
insert into product values(00001, 'Milk', 01000, 00000, 00004, 0);\
insert into product values(00002, 'Bread', 01000, 00000, 00001, 0);\
insert into product values(00003, 'Cheese', 01000, 00000, 00002, 0);\
insert into product values(00004, 'Wine', 01000, 00000, 000020, 0);\
insert into product values(00005, 'Ham', 01000, 00000, 00005, 0);}