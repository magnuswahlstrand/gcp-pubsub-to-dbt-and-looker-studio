package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"
)

type Item struct {
	ItemID string `json:"item_id"`
	Price  string `json:"price"`
}

type WeightedItem struct {
	Item
	Weight int `json:"weight"`
}

type OrderItem struct {
	Item
	Quantity int32 `json:"quantity"`
}

type OrderPlaced struct {
	OrderID    string      `json:"order_id"`
	CustomerID string      `json:"customer_id"`
	Items      []OrderItem `json:"items"`
	OrderDate  string      `json:"order_date"`
}

var items = []WeightedItem{
	{Item: Item{ItemID: "item_1", Price: "1.0"}, Weight: 80 - 10},
	{Item: Item{ItemID: "item_2", Price: "15.0"}, Weight: 80 - 15},
	{Item: Item{ItemID: "item_3", Price: "20.0"}, Weight: 80 - 20},
	{Item: Item{ItemID: "item_4", Price: "25.0"}, Weight: 80 - 25},
	{Item: Item{ItemID: "item_5", Price: "30.0"}, Weight: 80 - 30},
	{Item: Item{ItemID: "item_6", Price: "35.0"}, Weight: 80 - 35},
	{Item: Item{ItemID: "item_7", Price: "40.0"}, Weight: 80 - 40},
	{Item: Item{ItemID: "item_8", Price: "45.0"}, Weight: 80 - 45},
	{Item: Item{ItemID: "item_9", Price: "50.0"}, Weight: 80 - 50},
	{Item: Item{ItemID: "item_10", Price: "55.0"}, Weight: 80 - 55},
	{Item: Item{ItemID: "item_11", Price: "60.0"}, Weight: 80 - 60},
	{Item: Item{ItemID: "item_12", Price: "165.0"}, Weight: 80 - 65},
}

func pickItemWithWeight() Item {
	totalWeight := 0
	for _, item := range items {
		totalWeight += item.Weight
	}

	randInt := rand.Intn(totalWeight)
	for _, item := range items {
		randInt -= item.Weight
		if randInt < 0 {
			return item.Item
		}
	}

	return items[0].Item // Fallback, should never really happen
}

func main() {
	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID") // Set this to your GCP project ID
	topicID := "order_created"           // Set this to your topic ID

	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	topic := client.Topic(topicID)

	for i := 0; i < 100; i++ {
		orderId := fmt.Sprintf("order_%d", rand.Intn(100000))
		customerId := fmt.Sprintf("customer_%d", rand.Intn(10))

		items := []OrderItem{}
		seen := make(map[string]bool)
		for j := 0; j < rand.Intn(5)+1; j++ {
			item := pickItemWithWeight()
			if _, alreadySeen := seen[item.ItemID]; alreadySeen {
				continue
			}
			seen[item.ItemID] = true

			quantity := int32(rand.Intn(3) + 1)
			items = append(items, OrderItem{Item: item, Quantity: quantity})
		}

		randomDate := randomDate()

		message := OrderPlaced{
			OrderID:    orderId,
			CustomerID: customerId,
			Items:      items,
			OrderDate:  randomDate.Format(time.RFC3339),
		}

		msgData, err := json.Marshal(message)
		if err != nil {
			log.Fatalf("Error marshaling message: %v", err)
		}
		fmt.Println(string(msgData))

		result := topic.Publish(ctx, &pubsub.Message{
			Data: msgData,
		})

		// Block until the result is returned and log server-assigned message ID
		id, err := result.Get(ctx)
		if err != nil {
			log.Fatalf("Could not publish message: %v", err)
		}
		fmt.Printf("Published a message; msg ID: %v\n", id)

	}
}

func randomDate() time.Time {
	hour := rand.Intn(24)
	minute := rand.Intn(60)
	startDate := time.Date(2023, 1, 1, hour, minute, 0, 0, time.UTC)
	return startDate.AddDate(0, 0, rand.Intn(365))
}
