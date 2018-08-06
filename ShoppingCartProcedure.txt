{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf600
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww15480\viewh11460\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 create or replace procedure shopping_cart_procedure (arg_customer_id in NUMBER, arg_product_id in NUMBER, arg_quantity in NUMBER, arg_cancel in NUMBER, arg_checkout in NUMBER)\
is\
ws_stock number;\
ws_number number;\
ws_limit number;\
ws_limit2 number;\
ws_cart number;\
ws_cart3 number;\
ws_itemid number;\
ws_order number;\
ws_refund number;\
ws_maxprod number;\
ws_maxcus number;\
ws_order1 number;\
bad_stock exception;\
bad_insufficient exception;\
bad_limit exception;\
bad_toggle exception;\
bad_toggle2 exception;\
bad_toggle3 exception;\
bad_toggle4 exception;\
bad_toggle5 exception;\
bad_toggle6 exception;\
bad_toggle7 exception;\
begin\
--whole bunch of exceptions for every occasion \
if arg_cancel >= 1 AND arg_checkout >= 1 then raise bad_toggle;\
end if;\
if arg_cancel > 1 then raise bad_toggle2;\
end if;\
if arg_cancel < 0 then raise bad_toggle2;\
end if;\
if arg_checkout > 1 then raise bad_toggle2;\
end if;\
if arg_checkout < 0 then raise bad_toggle2;\
end if;\
if arg_checkout = 1 AND arg_quantity > 0 then raise bad_toggle3;\
end if;\
if arg_cancel = 1 AND arg_quantity > 0 then raise bad_toggle4;\
end if;\
if arg_quantity < 0 then raise bad_toggle5;\
end if;\
select max(p.product_id) into ws_maxprod from product p;\
if arg_product_id > ws_maxprod then raise bad_toggle6;\
end if;\
if arg_product_id < 0 then raise bad_toggle6;\
end if;\
select max(customer_id) into ws_maxcus from customer;\
if arg_customer_id > ws_maxcus then raise bad_toggle7;\
end if;\
if arg_customer_id < 0 then raise bad_toggle7;\
end if;\
--cannot add to cart if inadequate stock\
select max(p.quantity_on_hand) into ws_stock from product p\
where p.product_id = arg_product_id;\
if ws_stock = 0 then raise bad_stock;\
end if;\
if arg_quantity > ws_stock then raise bad_insufficient;\
end if;\
--total of new inserted item cannot exceed customer credit limit\
select max(p.product_price) * arg_quantity into ws_number from product p\
where p.product_id = arg_product_id;\
select max(c.credit_limit) into ws_limit2 from customer c\
where c.customer_id = arg_customer_id;\
if ws_number > ws_limit2 then raise bad_limit;\
end if;\
--reserve item while in shopping cart\
update product set quantity_on_hand = quantity_on_hand - arg_quantity where product_id = arg_product_id;\
--create new shopping cart if one doesn\'92t exist, otherwise insert into existing shopping cart\
select max(c.cart_customer) into ws_cart from shopping_cart c\
where c.cart_customer = arg_customer_id AND c.close_date is NULL;\
if ws_cart is NULL AND arg_checkout <> 1 then insert into shopping_cart values(shopping_cart_seq.nextval, arg_customer_id, sysdate, NULL);\
end if;\
select max(cart_id) into ws_cart3 from shopping_cart;\
--insert the new ordered item \
if arg_cancel = 0 AND arg_checkout = 0 AND arg_quantity > 0 then insert into ordering_items values(order_items.nextval, ws_cart3, arg_product_id, arg_quantity);\
end if;\
if arg_cancel = 0 AND arg_checkout = 1 AND arg_quantity > 0 then insert into ordering_items values(order_items.nextval, ws_cart3, arg_product_id, arg_quantity);\
end if;\
if arg_cancel = 0 and arg_checkout = 0 AND arg_quantity > 0 then update customer set credit_limit = credit_limit - ws_number where customer_id = arg_customer_id;\
end if;\
update customer set pay_period = pay_period + ws_number where customer_id = arg_customer_id;\
select max(o.ordering_items_id) into ws_order from ordering_items o;\
-- Order cancelled, then quantity returned to stock\
-- cannot remove an item from a cart, cancel and restart\
--- this section of the procedure isn't working\
if arg_cancel = 1 then update product p\
set p.quantity_on_hand = p.quantity_on_hand + (select max(product_quantity) \
                                               from ordering_items o join shopping_cart s on s.cart_id = o.shoppingcart_id \
                                               where o.product_id = p.product_id \
                                               AND s.cart_customer = arg_customer_id AND s.close_date is NULL)\
where p.product_id in (select o.product_id \
                       from ordering_items o join shopping_cart s on s.cart_id = o.shoppingcart_id \
                       where o.product_id = p.product_id \
                       AND s.cart_customer = arg_customer_id AND s.close_date is NULL);\
end if;\
if arg_cancel = 1 then update shopping_cart set close_date = sysdate where cart_customer = arg_customer_id;\
end if;\
--Returns credit to customer if purchase is canceled.\
if arg_cancel = 1 then update customer set credit_limit = credit_limit + pay_period where customer_id = arg_customer_id;\
end if;\
if arg_cancel = 1 then update customer set pay_period = 0 where customer_id = arg_customer_id;\
end if;\
--Assign order tracking number\
select max(o.ordercustomer_id) into ws_order1 from orders o \
where o.ordercustomer_id = arg_customer_id AND o.ship_date is NULL;\
if ws_order1 is NULL AND arg_checkout <> 1 then insert into orders values(orders_seq.nextval, ws_cart3, arg_customer_id, 'In-Process', sysdate, NULL);\
end if;\
if arg_checkout = 1 then update orders set ship_date = sysdate where ordercustomer_id = arg_customer_id;\
end if;\
if arg_checkout = 1 then update orders set order_status = 'Shipped' where ordercustomer_id = arg_customer_id;\
end if;\
if arg_cancel = 1 then update orders set order_status = 'Cancelled' where ordercustomer_id = arg_customer_id;\
end if;\
if arg_cancel = 1 then update orders set ship_date = sysdate where ordercustomer_id = arg_customer_id;\
end if;\
if arg_checkout = 1 then update shopping_cart set close_date = sysdate where cart_customer = arg_customer_id;\
end if;\
update product set quantity_sold = 1000 - quantity_on_hand;\
update product set product_restock = 1 where quantity_on_hand < 100;\
update product set product_restock = 0 where quantity_on_hand > 100;\
--Reset pay period upon checkout\
if arg_checkout = 1 then update customer set pay_period = 0 where customer_id = arg_customer_id;\
end if;\
EXCEPTION \
when bad_stock then raise_application_error(-20000, 'No Stock available');\
when bad_insufficient then raise_application_error(-20100, 'Insufficient stock');\
when bad_limit then raise_application_error(-20200, 'Cannot exceed credit limit');\
when bad_toggle then raise_application_error(-20300, 'Cannot checkout and cancel order at the same time');\
when bad_toggle2 then raise_application_error(-20400, 'Checkout and cancel cannot exceed the value 1 or be negative');\
when bad_toggle3 then raise_application_error(-20500, 'Cannot order and checkout at the same time');\
when bad_toggle4 then raise_application_error(-20600, 'Cannot cancel with a quantity greater than 0');\
when bad_toggle5 then raise_application_error(-20700, 'Quantity cannot be negative');\
when bad_toggle6 then raise_application_error(-20800, 'Invalid product ID');\
when bad_toggle7 then raise_application_error(-20900, 'Invalid customer ID');\
end;\
}